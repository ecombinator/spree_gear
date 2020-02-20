module Spree
  Promotion.class_eval do
    after_destroy :update_available_products

    def simple?
      return unless code.nil? || code == ""
      return unless rules.count == 1 && ["Spree::Promotion::Rules::Product", "Spree::Promotion::Rules::Taxon"].include?(rules.first.type)
      return unless actions.count == 1 && actions.first.type == "Spree::Promotion::Actions::CreateItemAdjustments"
      true
    end

    def applies_simply_to?(product)
      return true if products.any? && products.include?(product)
      return true if taxons.any? && (taxons.map(&:id) & product.taxons.map(&:id)).any?
      false
    end

    def taxons
      rules.where(type: 'Spree::Promotion::Rules::Taxon').map(&:taxons).flatten.uniq
    end

    def update_available_products
      AvailableProductsAttributeUpdateJob.perform_later
    end
  end
end
