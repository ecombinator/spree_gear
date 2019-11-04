module SpreeGear
  module Base
    module ViewHelpers
      module Json
        def cart_order_to_json(order)
          line_items = order.line_items
          order = order.as_json(only: [:id]).
            merge(
              quantity: order.quantity,
              shipping_cost: order.shipment_total.to_f,
              discounts: order.adjustment_total.to_f,
              total_cost: order.item_total.to_f,
              default_currency: "$"
            )
          product_and_images = []

          line_items.each do |line_item|
            product = line_item.product
            product_and_images << product.as_json(only: [:id, :name]).
              merge(
                main_image: image_or_default_for(product),
                link_to: product_path(product),
                quantity: line_item.quantity,
                display_price: line_item.cart_display_price(self),
                line_item_id: line_item.id
              )
          end
          order.merge(products_and_images: product_and_images.to_json)
        end

        def products_to_json(products, as_hash = false)
          product_and_images = []
          products.each do |product|
            product_and_images << product.as_json(only: [:id, :name]).
              merge(
                main_image: image_or_default_for(product),
                link_to: product_path(product, taxon_id: @taxon.try(:id)),
                on_sale: product.on_sale?,
                price: price_range_for(product),
                in_stock: product.total_on_hand.positive?,
                can_supply: product.can_supply?,
                master_id: product.master.id,
                master_price: product.master.price,
                default_currency: "$",
                category_name: product.first_category,
                discount_amount: product.discount_amount,
                discount_type: product.discount_type,
                multi_variants: product.variants_and_option_values(current_currency).any?
              )
          end
          return product_and_images if as_hash
          product_and_images.to_json
        end
      end
    end
  end
end
