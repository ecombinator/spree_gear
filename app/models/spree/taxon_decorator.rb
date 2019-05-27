module Spree
  Taxon.class_eval do
    after_update :update_product_taxonomies

    def self.category_root
      Rails.cache.fetch('category_taxon', expires_in: 1.minutes) do
        Spree::Taxon.find_by_permalink 'category'
      end
    end

    def self.species_root
      Rails.cache.fetch('species_taxon', expires_in: 1.minutes) do
        Spree::Taxon.find_by_permalink 'species'
      end
    end

    def self.species
      Rails.cache.fetch('species_taxons', expires_in: 1.minutes) do
        Spree::Taxon.where parent_id: Spree::Taxon.species_root.id
      end
    end

    def self.categories
      Rails.cache.fetch('category_taxons', expires_in: 1.minutes) do
        Spree::Taxon.where parent_id: Spree::Taxon.category_root.id
      end
    end

    def self.leaf_categories
      self.where("NOT EXISTS (SELECT 1 FROM spree_taxons tt WHERE tt.parent_id = spree_taxons.id)")
    end

    def self.category_ids
      categories.map &:id
    end

    def self.flower
      Rails.cache.fetch('flower_taxon', expires_in: 1.minutes) do
        Spree::Taxon.find_by_permalink 'category/flower'
      end
    end

    def self.vape_pens
      Rails.cache.fetch('vape_pens_taxon', expires_in: 1.minutes) do
        Spree::Taxon.find_by_permalink 'category/vape-pens'
      end
    end

    def self.concentrates
      Rails.cache.fetch('concentrates_taxon', expires_in: 1.minutes) do
        Spree::Taxon.find_by_permalink 'category/concentrates'
      end
    end

    private

    def update_product_taxonomies
      if taxonomy.name == "Brand"
        products.each &:update_brand_name
      end
      if taxonomy.name == "Category"
        products.each &:update_main_category_name
      end
    end
  end
end
