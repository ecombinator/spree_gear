module Spree
  ProductDuplicator.class_eval do
    def duplicate
      new_product = duplicate_product

      # don't dup the actual variants, just the characterising types
      new_product.option_types = product.option_types if product.has_variants?

      # allow site to do some customization
      new_product.send(:duplicate_extra, product) if new_product.respond_to?(:duplicate_extra)
      new_product.save!
      new_product
    end

    protected

    def duplicate_product
      product.dup.tap do |new_product|
        new_product.name = "COPY OF #{product.name}"
        new_product.taxons = product.taxons
        new_product.created_at = nil
        new_product.deleted_at = nil
        new_product.updated_at = nil
        new_product.product_properties = reset_properties
        new_product.master = duplicate_master

        copied_variants = []
        product.variants.each { |variant|
          option_value_ids = variant.option_values.map(&:id).sort
          next if copied_variants.include?(option_value_ids)
          new_variant = duplicate_variant variant
          new_product.variants << new_variant
          copied_variants << option_value_ids
        }
      end
    end

    def duplicate_master
      master = product.master
      master.dup.tap do |new_master|
        new_master.sku = sku_generator(master.sku)
        new_master.deleted_at = nil
        new_master.images = master.images.map { |image| duplicate_image image } if @include_images
        new_master.price = master.price
        new_master.wholesale_price = master.wholesale_price
        new_master.sold_to_consumers = master.sold_to_consumers
        new_master.sold_to_wholesalers = master.sold_to_wholesalers
        new_master.currency = master.currency
      end
    end

    def duplicate_variant(variant)
      new_variant = variant.dup
      new_variant.product_id = nil
      new_variant.price = variant.price
      new_variant.wholesale_price = variant.wholesale_price
      new_variant.sold_to_consumers = variant.sold_to_consumers
      new_variant.sold_to_wholesalers = variant.sold_to_wholesalers
      new_variant.sku = sku_generator(new_variant.sku)
      new_variant.deleted_at = nil
      new_variant.option_values = variant.option_values.map { |option_value| option_value }
      new_variant
    end

    def duplicate_image(image)
      new_image = image.dup
      new_image.assign_attributes(attachment: image.attachment.clone)
      new_image
    end

    def reset_properties
      product.product_properties.map do |prop|
        prop.dup.tap do |new_prop|
          new_prop.created_at = nil
          new_prop.updated_at = nil
        end
      end
    end

    def sku_generator(sku)
      return "" if sku == ""
      new_sku = "COPY OF #{Variant.unscoped.where("sku like ?", "%#{sku}").order(:created_at).last.sku}"
      while Variant.where(sku: new_sku).any?
        new_sku = "COPY OF #{new_sku}"
      end
      new_sku
    end

    def name_generator(name)
      new_name = "COPY OF #{name}"
      while Product.unscoped.where(name: new_name).any?
        new_name = "COPY OF #{new_name}"
      end
      new_name
    end

  end
end
