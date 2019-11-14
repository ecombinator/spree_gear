# frozen_string_literal: true
require_dependency 'spree/products/taxon_categories'
require_dependency 'spree/products/revenue_scopes'
require_dependency 'spree/products/weighing'
require_dependency 'spree/products/price_ranges'
require_dependency 'spree/products/helpers'
require_dependency 'spree/products/custom_scopes'
require_dependency 'spree/products/stock_availability'

module Spree
  Product.class_eval do
    include Spree::Product::TaxonCategories
    include Spree::Product::RevenueScopes
    include Spree::Product::Weighing
    include Spree::Product::PriceRanges
    include Spree::Product::Helpers
    include Spree::Product::CustomScopes
    include Spree::Product::StockAvailablity

    has_many :category_products,
             class_name: "Spree::CategoryProduct",
             foreign_key: "product_id",
             dependent: :destroy

    serialize :price_range
    serialize :wholesale_price_range

    delegate :cost_price, to: :master

    [ :wholesale_price, :sold_to_wholesalers, :sold_to_consumers
    ].each do |method_name|
      delegate method_name, :"#{method_name}=", to: :find_or_build_master
    end

    before_validation :ensure_shipping_category
    after_save :update_price_ranges
    after_update :update_availability_status
    after_update :update_brand_and_main_category

    self.whitelisted_ransackable_associations += ["classifications"]
    self.whitelisted_ransackable_attributes = ["description", "name", "slug", "taxon_ids"]

    validates :minimum_order, numericality: { greater_than_or_equal_to: 1 }

    _validators.delete(:slug)
    _validate_callbacks.each do |callback|
      if callback.raw_filter.respond_to? :attributes
        callback.raw_filter.attributes.delete :slug
      end
    end

    def update_brand_and_main_category
      update_brand_name
      update_main_category_name
    end

    def update_brand_name
      taxonomy = Spree::Taxonomy.find_by_name("Brand")
      return unless taxonomy
      update_column :brand_name,
                    taxons.where(taxonomy: taxonomy).order(:position).first&.name
    end

    def update_main_category_name
      taxonomy = Spree::Taxonomy.find_by_name("Category")
      return unless taxonomy
      update_column :main_category_name,
                    taxons.where(taxonomy: taxonomy).order("spree_taxons.depth, spree_taxons.position DESC").last&.name
    end

    def variants_on_sale
      return [] unless master.respond_to? :on_sale?
      @variants_on_sale ||= variants_including_master.select(&:on_sale?)
    end

    def on_sale?
      discount_amount > 0 || variants_on_sale.any?
    end

    def update_discount_attributes
      discount_amount = 0
      discount_type = nil

      if variants_on_sale.any?
        discount_type = "percent"
        variants_on_sale.each do |variant|
          discount_amount = [((variant.original_price - variant.sale_price) / variant.original_price * 100.00).round, discount_amount].max
        end
      else
        promo = Spree::Promotion.active.select do |promo|
          promo.simple? && promo.applies_simply_to?(self)
        end.last
        if promo
          action = promo.actions.where(type: "Spree::Promotion::Actions::CreateItemAdjustments").last

          if action&.calculator.is_a?(Calculator::PercentOnLineItem)
            discount_type = "percent"
            discount_amount = action.calculator.preferred_percent
          elsif action&.calculator.is_a?(Calculator::FlatRate)
            discount_type = "flat_rate"
            discount_amount = action.calculator.preferred_amount
          end
        end
      end

      update_columns discount_amount: discount_amount,
                     discount_type: discount_type
    end

    def can_supply?
      return variants.any?(&:can_supply?) if has_variants?
      variants_including_master.any? &:can_supply?
    end

    def in_stock?
      return variants.any?(&:in_stock?) if has_variants?
      variants_including_master.any? &:in_stock?
    end

    private

    def make_available
      self.available_on ||= Time.current
    end

    def ensure_shipping_category
      self.shipping_category ||= Spree::ShippingCategory.first
    end
  end
end

