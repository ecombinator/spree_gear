# frozen_string_literal: true

module SpreeGear
  module Importers
    class ProductImporter
      include HTTParty
      base_uri "#{ENV['WC_SITE_ROOT']}/wp-json/wc/v1"

      def initialize(key, secret)
        @auth = { consumer_key: key, consumer_secret: secret }
        @shipping_category_id = shipping_category = Spree::ShippingCategory.find_by_name("Default").id
        @location = Spree::StockLocation.first
      end

      def import!
        range = Rails.env.production? ? 1.100 : 1..2

        range.each do |page|
          puts "Page #{page}"
          woos = index(per_page: 10, page: page).parsed_response
          break if woos.empty?
          woos.each do |woo|
            begin
              import_product(woo)
            rescue => error
              puts " -> ERROR importing `#{woo["name"]}`"
            end
          end
        end
      end

      def name_and_taxon(woo_name)
        name, taxon = woo_name.match(/(.+)\s\(([^)]+)\)$/)&.captures
        return woo_name, nil if name.nil?
        return woo_name, nil if taxon && Spree::Taxon.where(name: taxon).none?
        return name, taxon
      end

      def find_product(name, taxon)
        products = Spree::Product.where(name: name, shipping_category_id: @shipping_category_id)
        return nil unless products.any?
        products.each do |product|
          return product if product.taxons.none? && taxon.nil?
          return product if product.taxons.none? && !woo["variations"]
          return product if product.taxons.order(:depth).last&.name == taxon
        end
        nil
      end

      def import_product(woo)
        puts "Adding `#{woo['name']}`"

        name, taxon = name_and_taxon(woo["name"])
        product = find_product name, taxon
        product ||= Spree::Product.find_by_woo_id woo["id"].to_i
        product = nil if taxon && product&.deepest_taxon && product.deepest_taxon&.name == taxon
        if product.nil?
          puts " -> Creating `#{name}`"
          product = Spree::Product.find_or_initialize_by(name: name, shipping_category_id: @shipping_category_id)
        else
          puts " -> Found `#{name}`"
        end
        is_new = product.new_record?
        product.slug ||= woo["slug"]
        product.woo_id ||= woo["id"].to_i
        product.name = name
        product.price = woo["price"].to_f
        product.description = woo["description"]
        product.master.sold_to_wholesalers = true
        product.master.sold_to_consumers = true
        product.available = (woo["status"] == "publish")
        puts " -> product #{product.available && "is" || "IS NOT" } available"
        product.save!

        if is_new
          woo["categories"].each do |category|
            taxon = Spree::Taxon.where(name: category["name"]).first
            next unless taxon
            product.taxons << taxon unless product.taxons.where(id: taxon.id).any?
          end
          add_images(product, woo["images"]) if woo["images"]
        end

        set_stock(product.master.id, woo["stock_quantity"].to_i) unless woo["stock_quantity"].nil?
        if woo["type"] == "variable"
          add_variants(product, woo) if woo["variations"]
        else
          if woo["on_sale"]
            product.update price: woo["regular_price"].to_f
            product.put_on_sale woo["sale_price"].to_f
          end
        end
        puts " -> Done #{name} (#{product.taxons.order(:depth).last&.name})"
      end

      def add_images(product, images)
        images.each do |image|
          src = image["src"]
          next unless product.images.find_by_attachment_file_name(File.basename(src)).nil?
          puts " -> Adding image `#{src}`"
          product.images.create! attachment_remote_url: src, alt: image["alt"]
        end
      end

      def set_stock(variant_id, quantity)
        quantity = 0 if quantity.nil? || quantity.negative?
        Spree::StockItem.find_by(stock_location_id: @location.id, variant_id: variant_id).update! count_on_hand: quantity, backorderable: false
      end

      def standardize_option(value_name)
        value_name = "Single Gram" if value_name == "Gram" || value_name == "Full Gram"
        value_name = value_name.gsub(/\sOunce/, "")
        value_name = "Eighth" if value_name == "3.5"
        value_name = "Quarter" if value_name == "7"
        value_name = "Half" if value_name == "14" || value_name == "0.5"
        value_name = "Ounce" if value_name == "28"
        value_name = "X-Large" if value_name == "XL"
        value_name = "XX-Large" if value_name == "XXL" || value_name == "Double XL"
        value_name
      end

      def add_variants(product, woo)
        woo["variations"].each do |variation|
          begin
            next if variation["attributes"].empty?
            value_name = standardize_option(variation["attributes"][0]["option"])

            if value_name =~ /One .+/ || value_name =~ /1 .+/ || ["1", "2oz Jar"].include?(value_name)
              variant = product.master
            else

              option_value = Spree::OptionValue.find_by_presentation value_name
              unless option_value
                puts " -! Can't find option value `#{value_name}`"
                next
              end

              option_type = Spree::ProductOptionType.find_or_create_by product: product, option_type: option_value.option_type, position: 1
              variant = product.variants.joins(:option_values).where(spree_option_values: { id: option_value.id }).first
              if variant.nil?
                variant = product.variants.new is_master: false
                variant.option_values << option_value
                variant.price = variation["price"].to_f
                variant.save!
                puts " -> Added variant `#{value_name}` with price #{variant.price}"
              else
                puts " -> Found variant `#{value_name}` with price #{variant.price}"
              end
            end

            variant.update! sold_to_wholesalers: true, sold_to_consumers: true, price: variation["price"].to_f
            set_stock(variant.id, variation["stock_quantity"].to_i)
            puts " -> `#{value_name}` has #{variant.total_on_hand} units in stock"
            next unless variation["on_sale"]
            variant.update price: variation["regular_price"].to_f
            variant.put_on_sale variation["sale_price"].to_f
            puts " -> Put variant `#{value_name}` on sale with price #{variant.price}"
          rescue => error
            puts " -> ERROR\n#{variant.inspect}"
          end
        end
      end

      # which can be :friends, :user or :public
      # options[:query] can be things like since, since_id, count, etc.
      def index(options = {})
        options.merge! @auth
        self.class.get("/products", query: options)
      end
    end

  end
end
