# A rule to apply to an order greater than (or greater than or equal to)
# a specific amount
module Spree
  class Promotion
    module Rules
      module OptionValueWithNumerificationSupport
        def preferred_eligible_values
          values = super || {}
          Hash[values.keys.map(&:to_i).zip(
              values.values.map do |v|
                (v.is_a?(Array) ? v : v.split(',')).map(&:to_i)
              end
          )]
        end
      end

      class TaxonOptionTotal < PromotionRule

        prepend OptionValueWithNumerificationSupport
        MATCH_POLICIES = %w(any)
        preference :match_policy, :string, default: MATCH_POLICIES.first
        preference :eligible_values, :hash

        preference :amount_min, :decimal, default: 100.00
        preference :operator_min, :string, default: '>'
        preference :amount_max, :decimal, default: 1000.00
        preference :operator_max, :string, default: '<'

        OPERATORS_MIN = ['gt', 'gte']
        OPERATORS_MAX = ['lt', 'lte']

        has_many :promotion_rule_taxons, class_name: 'Spree::PromotionRuleTaxon', foreign_key: 'promotion_rule_id'
        has_many :taxons, through: :promotion_rule_taxons, class_name: 'Spree::Taxon'

        def applicable?(promotable)
          promotable.is_a?(Spree::Order)
        end

        def eligible?(order, _options = {})
          actionable_items = actionable_line_items(order)
          return unless actionable_items.any?

          item_total = actionable_items.inject(0) { |sum, li| sum += li.quantity * li.price }

          lower_limit_condition = item_total.send(preferred_operator_min == 'gte' ? :>= : :>, BigDecimal.new(preferred_amount_min.to_s))
          upper_limit_condition = item_total.send(preferred_operator_max == 'lte' ? :<= : :<, BigDecimal.new(preferred_amount_max.to_s))

          eligibility_errors.add(:base, ineligible_message_max) unless upper_limit_condition
          eligibility_errors.add(:base, ineligible_message_min) unless lower_limit_condition

          eligibility_errors.empty?
        end

        def actionable?(line_item)
          option_actionable?(line_item) && taxon_actionable?(line_item)
        end

        def taxon_actionable?(line_item)
          taxon_product_ids.include? line_item.variant.product_id
        end

        def option_actionable?(line_item)
          line_item_value_ids = line_item.variant.option_values.pluck(:id)
          (option_value_ids - line_item_value_ids).empty?
        end

        def actionable_line_items(order)
          order.line_items.select { |item| actionable?(item) }
        end

        def actionable_item_total(order)
          actionable_line_items(order).inject(0) { |sum, li| sum += li.quantity * li.price }
        end

        def taxon_ids_string
          taxons.pluck(:id).join(',')
        end

        def taxon_ids_string=(s)
          ids = s.to_s.split(',').map(&:strip)
          self.taxons = Spree::Taxon.find(ids)
        end

        private

        def taxon_product_ids
          Spree::Product.joins(:taxons).where(spree_taxons: {id: taxons.pluck(:id)}).pluck(:id).uniq
        end

        def formatted_amount_min
          Spree::Money.new(preferred_amount_min).to_s
        end

        def formatted_amount_max
          Spree::Money.new(preferred_amount_max).to_s
        end

        def ineligible_message_max
          if preferred_operator_max == 'gte'
            eligibility_error_message(:item_total_more_than_or_equal, amount: formatted_amount_max)
          else
            eligibility_error_message(:item_total_more_than, amount: formatted_amount_max)
          end
        end

        def ineligible_message_min
          if preferred_operator_min == 'gte'
            eligibility_error_message(:item_total_less_than, amount: formatted_amount_min)
          else
            eligibility_error_message(:item_total_less_than_or_equal, amount: formatted_amount_min)
          end
        end

        def product_ids
          preferred_eligible_values.keys
        end

        def option_value_ids
          preferred_eligible_values.values.flatten
        end
      end
    end
  end
end
