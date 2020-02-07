module SpreeGear
  module Base
    module ViewHelpers
      module Products
        def date_string_for(datetime)
          datetime.strftime("%b %e, %Y")
        end

        def image_or_default_for(product, format = (Rails.env.production? && :large || :product))
          if product.images.any? && product.images.first.attachment.exists?(format)
            product.images.first.attachment.url(format)
          else
            image_url "no-product-img.png"
          end
        end

        def deepest_taxon_for(product)
          product.deepest_taxon&.name&.singularize || ""
        end

        # def price_range_for(product)
        #  if defined? current_order
        #    range = current_order&.wholesale? ? product.wholesale_price_range : product.price_range
        #    range ||= current_order&.wholesale? ? product.latest_price_range[0] : product.latest_price_range[1]
        #  else
        #    range ||= product.wholesale_price_range
        #  end
        #  range.uniq.map { |p| number_to_currency(p, precision: 0) }.join(" - ")
        #end

        def price_range_for(product, options = {force_wholesaler_range: false, force_consumer_range: false})
          range = nil
          if options[:force_wholesaler_range] || (spree_current_user.present? && spree_current_user.wholesaler? && !options[:force_consumer_range])
            range = product.wholesale_price_range
          else
            range = product.price_range
          end
          range.uniq.map { |p| number_to_currency(p, precision: 0) }.join(" - ")
        end

        def stock_text(variant)
          variant.total_on_hand.positive? ? "#{variant.total_on_hand} on hand" : "out of stock"
        end

        def stock_class_suffix(variant)
          variant.can_supply? ? "success" : "danger"
        end
      end
    end
  end
end
