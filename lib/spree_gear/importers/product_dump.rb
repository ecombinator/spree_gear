require 'yaml'

module SpreeGear
  module Importers
    class ProductDump
      def export_products(options = {name: "products_dump", product_range: 0..-1})
        timestamp = Time.zone.now.to_time.to_i
        export_file_name = "#{options[:name]}_#{timestamp}.yml"
        dump = {products: {}, taxons: {}, option_types: {}}
        puts "Commenceing iteration for products"
        Spree::Product.all[options[:product_range]].each_with_index do |product, index|
          product_as_hash = product.as_json(only: whitelisted_product_attributes).merge(
            "taxons" => product.taxons.map(&:name), price: product.price&.to_f || 0, "variants" => {},
            "option_values" => {}, "wholesale_price" => product.wholesale_price, "cost_price" => product.cost_price,
            "image_ids" => product.images.map(&:id)
          )
          product.variants.each_with_index do |variant, index2|
            puts "- Merging Variant##{variant.id} (descent of #{product.name})"
            product_as_hash["variants"].merge!(
              index2 => variant.as_json(only: whitelisted_variant_attributes).merge(
                "option_values" => {},
                "price" => variant.price.to_f
              )
            )
            variant.option_values.each_with_index do |option_value, index3|
              product_as_hash["variants"][index2]["option_values"].merge!(
                index3 => option_value.as_json(only: whitelisted_option_type_attributes).
                merge("option_type_name" => option_value.option_type.name)
              )
            end
          end
          product.options.each_with_index do |option_value, index2|
            puts "- Adding option value '#{option_value.option_type.name}'"
            product_as_hash["option_values"].merge!(
              index2 => option_value.as_json(only: whitelisted_option_type_attributes).
                merge("option_type_name" => option_value.option_type.name)
            )
          end
          dump[:products].merge!(index => product_as_hash)
          puts "Merging Product##{product.id}"
        end
        puts "Products merging finish!\n"

        puts "Commenceing iteration for taxons"
        Spree::Taxon.categories.each_with_index do |taxon, index1|
          puts "Merging Taxon##{taxon.id}"
          taxon_as_hash = taxon.as_json(only: whitelisted_taxon_attributes).merge(descendants: {})
          taxon.descendants.each_with_index do |descendant, index2|
            puts "- Merging Taxon descendant ##{descendant.id} for Taxon##{taxon.id}"
            taxon_as_hash[:descendants].merge!(index2 => descendant.as_json(only: whitelisted_taxon_attributes))
          end
          dump[:taxons].merge!(index1 => taxon_as_hash)
        end
        puts "Taxons merging finish!\n"

        puts "Commencing iteration of option types"
        Spree::OptionType.all.each_with_index do |option_type, index1|
          puts "Merging option type: '#{option_type.name}'"
          option_type_as_hash = option_type.as_json(only: whitelisted_option_type_attributes).merge("option_values" => {})
          option_type.option_values.each_with_index do |option_value, index2|
            option_type_as_hash["option_values"].merge!(index2 => option_value.as_json(only: whitelisted_option_type_attributes))
          end
          dump[:option_types].merge!(index1 => option_type_as_hash)
        end
        puts "Option Type merging finish!\n"
        File.open(export_file_name, 'a') {|f| f.write(dump.to_yaml) }
        puts "dump saved as #{export_file_name}"
      end

      def import_products(file_name)
        puts "reading #{file_name}"
        dump = YAML::load(File.read(file_name))
        # Spree::Taxon.all.each {|f| f.destroy unless f.name == "Category"}
        # Spree::Product.all.each {|f| f.destroy }
        # Spree::Variant.all.each {|f| f.destroy }
        # Spree::OptionType.all.each {|f| f.destroy }
        puts "initiating taxon iteration"
        dump[:taxons].each do |key, taxon|
          puts "ERROR/WARNING: Category Taxon MISSING!" unless Spree::Taxon.find_by_name("Category").present?
          taxon_hash_create(taxon, parent_id: Spree::Taxon.find_by_name("Category").try(:id))
          if taxon[:descendants].any?
            taxon[:descendants].each do |key2, descendant|
              taxon_hash_create(descendant, parent_id: Spree::Taxon.find_by_name(taxon["name"]).try(:id))
            end
          end
        end
        puts "initiating option types iteration"
        dump[:option_types].each do |key, option_type|
          if selected_optiontype = Spree::OptionType.find_by(name: option_type["name"], presentation: option_type["presentation"])
            puts "#{selected_optiontype.name} already exists"
            option_type["option_values"].each do |key2, hased_option_value|
              option_value_create(selected_optiontype, hased_option_value)
            end

          else
            new_option_type = Spree::OptionType.new
            whitelisted_option_type_attributes.each do |option_attr|
              new_option_type.send("#{option_attr}=", option_type[option_attr.to_s])
            end
            if new_option_type.save
              puts "successfuly saves #{new_option_type.name}"
              option_type["option_values"].each do |key2, hased_option_value|
                option_value_create(new_option_type, hased_option_value)
              end
            else
              puts "error saving #{option_type['name']}, #{new_option_type.errors.messages}"
            end
          end
        end

        puts "initiating products iteration"

        dump[:products].each do |key, product_hashed|
          if !(Spree::Product.where(slug: product_hashed["slug"]).any?)
            new_product = Spree::Product.new
            whitelisted_product_attributes.each do |product_attr|
              new_product.send("#{product_attr}=", product_hashed[product_attr.to_s])
            end
            new_product.price = product_hashed[:price]

            if new_product.save
              puts "Successfuly saves #{new_product.name}"
              product_hashed["taxons"].each do |taxon_name|
                if selected_taxon = Spree::Taxon.find_by_name(taxon_name)
                  new_product.taxons << selected_taxon
                else
                  puts "Warning: missing taxon ' #{taxon_name} ' in database"
                end
              end
              product_hashed["option_values"].each do |key2, option_value_name|
                new_option = new_product.options.create(option_type: Spree::OptionType.find_by_name(option_value_name["option_type_name"]))
                puts "- Adds option value '#{option_value_name}' to #{new_product.name}"
              end
              product_hashed["variants"].each do |key2, variant_hashed|
                new_variant = new_product.variants.new
                whitelisted_variant_attributes.each do |variant_attr|
                  new_variant.send("#{variant_attr}=", variant_hashed[variant_attr.to_s])
                end
                variant_hashed["option_values"].each do |key3, option_value_hashed|
                  new_variant.option_value_variants.build(option_value: Spree::OptionValue.find_by_name(option_value_hashed["name"]))
                end
                new_variant.price = variant_hashed["price"]
                if new_variant.save(validate: false)
                  puts "- successfuly saves Variant##{new_variant.id} of #{new_product.name}"
                else
                  puts "error saving a variant of #{new_product.name}, #{new_variant.errors.messages}"
                end
              end
            else
              puts "\n error in saving #{product_hashed['name']} #{new_product.errors.messages}\n"
            end
          else
            puts "Skipping #{product_hashed['name']} due to duplicate slug"
          end
        end

        puts "import complete"
      end

      def import_images(file_name)
        folder_location = "attachments"
        puts "import images start, location: #{Rails.root.join "#{folder_location}/IMAGE_ID", "large.jpeg"}"
        dump = YAML::load(File.read(file_name))
        dump[:products].each do |key, product_hashed|
          product_hashed["image_ids"].each do |image_id|
            image_path = Rails.root.join "#{folder_location}/#{image_id}", "large.jpeg"
            if File.exist? image_path
              if selected_product = Spree::Product.find_by(slug: product_hashed["slug"])
                selected_product.images.create! attachment: File.open(image_path)
                puts "-> Imports #{image_id} for #{selected_product.name}"
              else
                puts "WARNING: slug not found, skipping image transition for image id ##{image_id}, '#{product_hashed['name']}'"
                next
              end
            else
              puts "File does not exist for image name ##{image_id}"
            end
          end
        end

        puts "import complete"
      end

      private

      def taxon_hash_create(taxon_hash, extra_attributes = {})
        if Spree::Taxon.where(name: taxon_hash["name"]).any?
          puts "skipping #{taxon_hash['name']} due to duplicate name"
          return
        end
        selected_taxon = Spree::Taxon.new
        whitelisted_taxon_attributes.each do |taxon_attr|
          selected_taxon.send("#{taxon_attr}=", taxon_hash[taxon_attr.to_s])
        end
        extra_attributes.each do |key, key_attr|
          selected_taxon.send("#{key}=", key_attr)
        end
        if selected_taxon.save
          puts "Successfuly saved #{taxon_hash['name']}(##{selected_taxon.id})"
        else
          puts "\n Error(s) with taxon '#{taxon_hash['name']}': #{selected_taxon.errors.messages} \n"
        end
      end

      def option_value_create(option_type, hashed_option_value)
        return if Spree::OptionValue.find_by_name(hashed_option_value["name"]).present?
        new_option_value = option_type.option_values.new
        whitelisted_option_type_attributes.each do |option_attr|
          new_option_value.send("#{option_attr}=", hashed_option_value[option_attr.to_s])
        end
        if new_option_value.save
          puts "- Success saving #{new_option_value.name} to #{option_type.name}"
        else
          puts "- error saving #{hashed_option_value['name']}, #{new_option.errors.messages}"
        end
      end

      def whitelisted_option_type_attributes
        [:name, :presentation ]
      end

      def whitelisted_taxon_attributes
        [ :name, :permalink ]
      end

      def whitelisted_variant_attributes
        [:sku, :weight, :height, :width, :depth, :is_master, :cost_price,
          :track_inventory, :wholesale_price, :sold_to_consumers, :sold_to_wholesalers, :stocked_for_the_week ]
      end

      def whitelisted_product_attributes
        [
          :name, :description,
          :slug, :meta_description,
          :meta_keywords, :promotionable,
          :meta_title, :stocked_for_the_week, :price_range,
          :wholesale_price_range, :wholesale_price, :cost_price
        ]
      end
    end
  end
end
