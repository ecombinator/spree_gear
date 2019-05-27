module SpreeGear
  module Base
    module ViewHelpers
      module Global
        def gravatar_url(user_email)
          "https://www.gravatar.com/avatar/#{Digest::MD5.hexdigest(user_email)}"
        end

        def current_path(params={})
          url_for(request.params.merge(params))
        end

        def is_in_a_product_index?
          @body_id.present? && (@body_id == "products-index" || @body_id == "taxons-show")
        end

        def minimum_shipping_amount
          return 0 unless Spree::Promotion.find_by(name: ENV["SHIPPING_PROMOTION_NAME"]).present?
          Spree::Promotion.find_by(name: ENV["SHIPPING_PROMOTION_NAME"]).rules.first.preferences[:amount_min]
        end

        def path_without_cart
          controller_name == "checkout" || controller_name == "orders" && action_name == "edit"
        end

        def cart_has_items?
          current_order && current_order.quantity > 0
        end


        # add order_to_json helper here later
      end
    end
  end
end
