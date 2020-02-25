module Spree
  class Product < Spree::Base
    module Weighing
     extend ActiveSupport::Concern
      included do
        # after_save :add_weight_option_type, if: :has_multiple_weights?
        # after_save :add_all_weight_variants, if: :has_weighty_taxons?

        def lightest_variant(matching_attributes) # returns nil for products with no weight OptionType
          variants.where(**matching_attributes).select(&:weight_option_value).sort_by(&:weight_in_grams).first
        end

        def heaviest_variant # returns nil for products with no weight OptionType
          variants.select(&:weight_option_value).sort_by(&:weight_in_grams).last
        end

        def lightest_or_master_variant(matching_attributes = {})
          lightest_variant(matching_attributes) || master
        end

        def has_weight_option_type?
          option_types.where(name: "Weight").any?
        end

        def has_multiple_weights?
          return false unless has_weight_option_type?
          variants.map(&:weight_option_value).compact.uniq.length > 1
        end

        def has_weighty_taxons?
          has_taxons_by_permalink? Rails.application.config.weighty_permalinks
        end

        def has_taxons_by_permalink?(permalinks)
          return false unless permalinks.any?
          taxons.any? do |taxon|
            permalinks.any? do |permalink|
              taxon.permalink.start_with?(permalink)
            end
          end
        end

        def current_weight_option_values
          weight_values = Spree::OptionValue.weights
          variants.map do |variant|
            variant.option_values.where(id: weight_values)
          end.flatten
        end

        def add_weight_option_type
          option_types << Spree::OptionType.find_by_name("Weight") unless has_weight_option_type?
        end

        private

        def missing_weight_option_values
          Spree::OptionValue.weights - current_weight_option_values
        end

        def add_all_weight_variants
          return if current_weight_option_values.count > 1

          missing_weight_option_values.each do |missing_value|
            variant = variants.create option_values: [missing_value]
            variant.weight = variant.weight_in "g"
            variant.cost_price = variant.default_weight_cost
            variant.save!
            price = variant.prices.first
            price.amount = variant.default_weight_price
            price.save!
          end
        end
      end
    end
  end
end
