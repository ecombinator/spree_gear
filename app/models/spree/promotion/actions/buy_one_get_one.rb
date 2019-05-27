module Spree
  class Promotion
    module Actions
      class BuyOneGetOne < PromotionAction
        def perform(options={})
          return unless order = options[:order]

          eligible_variant_ids = get_eligible_variant_ids_from_promo_rule
          return unless eligible_variant_ids.present?

          order.line_items.where(variant_id: eligible_variant_ids).each do |li|
            if li.price != 0
              # It's an eligible variant and it's price is not zero, so we
              # found a "buy one" line item.


              matching_get_one_line_item = find_matching_get_one_line_item(li)

              # Create or update matching promo line item.
              if matching_get_one_line_item
                matching_get_one_line_item.update_attribute(:quantity, li.quantity)
              else
                create_matching_get_one_line_item(li)
              end

            else
              # It's an eligible variant and it's price is zero, so we
              # found a "get one" line item.

              # Verify "buy one" line item still exists, else destroy
              # the "get one" line item
              li.destroy unless find_matching_buy_one_line_item(li)
            end
          end
        end

        def get_eligible_variant_ids_from_promo_rule
          product_rule = promotion.promotion_rules.detect do |rule|
            # If not using the Product rule, update this line
            rule.is_a? Spree::Promotion::Rules::Product
          end
          return unless product_rule.present?

          eligible_products = product_rule.products
          return unless eligible_products.present?

          eligible_products.collect {|p| p.variant_ids}.flatten.uniq
        end

        def find_matching_buy_one_line_item(get_one_line_item)
          get_one_line_item.order.line_items.detect do |li|
            li.variant_id == get_one_line_item.variant_id and li.price != 0
          end
        end

        def create_matching_get_one_line_item(buy_one_line_item)
          # You may need to update this with other custom attributes you've added.
          new_line_item = buy_one_line_item.order.line_items.build
          new_line_item.variant = buy_one_line_item.variant
          new_line_item.currency = buy_one_line_item.currency
          new_line_item.price = 0
          new_line_item.quantity = buy_one_line_item.quantity

          new_line_item.immutable = true
          new_line_item.additional_text = "Buy One Get One"

          new_line_item.save
        end

        def find_matching_get_one_line_item(buy_one_line_item)
          buy_one_line_item.order.line_items.detect do |li|
            li.variant_id == buy_one_line_item.variant_id and li.price == 0
          end
        end
      end
    end
  end
end
