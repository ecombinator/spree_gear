# A rule to apply to an order greater than (or greater than or equal to)
# a specific amount
module Spree
  class Promotion
    module Rules
      class TaxonTotal < PromotionRule
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
          item_total = order_taxon_line_items(order, taxons).inject(0) { |sum, li| sum += li.quantity * li.price }

          lower_limit_condition = item_total.send(preferred_operator_min == 'gte' ? :>= : :>, BigDecimal.new(preferred_amount_min.to_s))
          upper_limit_condition = item_total.send(preferred_operator_max == 'lte' ? :<= : :<, BigDecimal.new(preferred_amount_max.to_s))

          eligibility_errors.add(:base, ineligible_message_max) unless upper_limit_condition
          eligibility_errors.add(:base, ineligible_message_min) unless lower_limit_condition

          unless (taxons.to_a - taxons_in_order_including_parents(order)).empty?
            eligibility_errors.add(:base, eligibility_error_message(:missing_taxon))
          end

          eligibility_errors.empty?
        end

        def actionable?(line_item)
          return false if !promotion.simple? && Spree::Product.find(line_item.variant.product_id).on_sale?
          taxon_product_ids.include? line_item.variant.product_id
        end

        def taxon_ids_string
          taxons.pluck(:id).join(',')
        end

        def taxon_ids_string=(s)
          ids = s.to_s.split(',').map(&:strip)
          self.taxons = Spree::Taxon.find(ids)
        end

        private

        def order_taxon_line_items(order, taxons)
          items = order.line_items.joins(variant: { product: :taxons}).where(spree_taxons: { id: taxons.map(&:id) }).distinct
          items
        end

        # All taxons in an order
        def order_taxons(order)
          Spree::Taxon.joins(products: {variants_including_master: :line_items}).where(spree_line_items: {order_id: order.id}).distinct
        end

        # ids of taxons rules and taxons rules children
        def taxons_including_children_ids
          taxons.inject([]){ |ids,taxon| ids += taxon.self_and_descendants.ids }
        end

        # taxons order vs taxons rules and taxons rules children
        def order_taxons_in_taxons_and_children(order)
          order_taxons(order).where(id: taxons_including_children_ids)
        end

        def taxons_in_order_including_parents(order)
          order_taxons_in_taxons_and_children(order).inject([]){ |taxons, taxon| taxons << taxon.self_and_ancestors }.flatten.uniq
        end

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
      end
    end
  end
end
