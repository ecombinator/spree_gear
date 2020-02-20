class AvailableProductsAttributeUpdateJob < ApplicationJob
  def perform
    Spree::Product.available.each do |product|
      ProductAttributeUpdateJob.perform_now(product)
    end
  end
end