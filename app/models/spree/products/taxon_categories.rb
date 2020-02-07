module Spree
  class Product < Spree::Base
    module TaxonCategories
     extend ActiveSupport::Concern
      included do
        TAXON_CATEGORIES_LIST = %w(flower concentrates vapor_pens indica sativa hybrid shatter)

        scope :sorted_by_category, -> {
          joins(:taxons)
              .where(spree_taxons: { id: Spree::Taxon.category_ids })
              .order("spree_taxons.id, spree_products.name")
        }

        scope :category_products, -> {
          joins(:taxons)
              .where(spree_taxons: { id: Spree::Taxon.category_ids })
              .order("spree_taxons.id, spree_products.name")
        }

        scope :by_category, ->(category) {
          joins(:taxons).where(spree_taxons: { permalink: "product-category/#{category}" }).order(:name)
        }

        scope :by_category_name, -> (names) {
          joins(:taxons).where(name: names)
        }

        scope :category_counts, -> {
          joins(:taxons).group("spree_taxons.name").count
        }

        scope :option_type_counts, -> {
          joins(:option_types).group("spree_option_types.name").count
        }

        TAXON_CATEGORIES_LIST.each do |type|
          scope(type.pluralize.to_sym, lambda do
            joins(:taxons).where(spree_taxons: { id: Spree::Taxon.send(type).id })
          end)

          define_method "is_#{type.singularize}?" do
            taxons.where(id: Spree::Taxon.send(type).id).any? unless Spree::Taxon.send(type).nil?
          end
        end

        def deepest_taxon
          taxons.order(:depth).last
        end

        def self.flower
          Spree::Product.by_category("flower")
        end

        def flower?
          taxons.where(spree_taxons: { permalink: "product-category/flower" }).any?
        end

        def category_taxon
          taxons.find_by_parent_id Spree::Taxon.category_root.id
        end

        def replace_species_taxon(new_species_taxon_id)
          replace_taxon_by_root new_species_taxon_id, Spree::Taxon.species_root
        end

        def replace_category_taxon(new_category_taxon_id)
          replace_taxon_by_root new_category_taxon_id, Spree::Taxon.category_root
        end

        def species_taxon
          taxons.find_by_parent_id Spree::Taxon.species_root.id
        end

        def related_products
          categories = Array.new
          self.taxons.each do |taxon|
            categories << taxon.name
          end
          Spree::Product.available_no_distinct.joins(:taxons).where(spree_taxons: {name: categories}).where.not(id: self.id)
        end

        def first_category
          return "" unless taxons.any?
          taxons&.first&.name
        end

        private

        def replace_taxon_by_root(new_taxon_id, root)
          if new_taxon_id.nil?
            taxons.delete taxons.where(parent_id: root.id)
          else
            taxons.delete taxons.where(parent_id: root.id).where.not(id: new_taxon_id)

            if new_record?
              classifications.where(taxon_id: new_taxon_id).first_or_initialize
            else
              classifications.where(taxon_id: new_taxon_id).first_or_create
            end
          end
        end
      end
    end
  end
end
