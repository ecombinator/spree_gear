module Spree
  class Product < Spree::Base
    module CustomScopes
     extend ActiveSupport::Concern
      included do
        scope :not_available, -> {
          where(available_on: nil).or(where.not(discontinue_on: nil))
        }

        scope :by_keyword, ->(keyword) {
          joins(:variants_including_master)
              .where("spree_products.name ILIKE ? OR spree_variants.sku ILIKE ?", "%#{keyword}%", "%#{keyword}%")
              .distinct
        }

        scope :highest_ratings, -> {
          joins(:reviews).order("spree_reviews.rating DESC")
        }


        scope :ascend_by_main_category_name, -> { order("supply_available desc, main_category_name, brand_name, spree_products.name") }
        scope :ascend_by_brand_name, -> { order("supply_available desc, brand_name, main_category_name") }

        # Variants Pricing

        scope :descend_by_variant_pricing, -> {
          # highest price
          order(consumer_highest_price: :desc)
        }

        scope :ascend_by_variant_pricing, -> {
          # lowest price
          order(consumer_lowest_price: :asc)
        }

        scope :descend_by_variant_pricing_wholesaler, -> {
          # highest price
          order(wholesaler_highest_price: :desc)
        }

        scope :ascend_by_variant_pricing_wholesaler, -> {
          # lowest price
          order(wholesaler_lowest_price: :asc)
        }

        scope :variant_prices_between, ->(lowest_price = 0, highest_price = 0) {
          where("consumer_lowest_price >= ? AND consumer_highest_price <= ?", lowest_price.to_f, highest_price.to_f)
        }

        scope :variant_prices_between_wholesaler, ->(lowest_price = 0, highest_price = 0) {
          where("wholesaler_lowest_price >= ? AND wholesaler_highest_price <= ?", lowest_price.to_f, highest_price.to_f)
        }

        def self.lowest_and_highest_consumer_prices
          [
            self.ascend_by_variant_pricing.first.consumer_lowest_price,
            self.descend_by_variant_pricing.first.consumer_highest_price
          ]
        end

        def self.lowest_and_highest_wholesaler_prices
          [
            self.ascend_by_variant_pricing_wholesaler.first.consumer_lowest_price,
            self.ascend_by_variant_pricing_wholesaler.first.consumer_highest_price
          ]
        end

        # sold to scopes

        scope :sold_to_consumers, -> {
          includes(:variants_including_master).where(spree_variants: { sold_to_consumers: true, is_master: true })
        }

        scope :sold_to_wholesalers, -> {
          includes(:variants_including_master).where(spree_variants: {sold_to_wholesalers: true, is_master: true})
        }

        # product supply availability

        scope :by_supply, -> {
          order(supply_available: :desc)
        }
      end
    end
  end
end
