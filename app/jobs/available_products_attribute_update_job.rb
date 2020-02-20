class AvailableProductsAttributeUpdateJob < ApplicationJob
  def perform
    Spree::Product.available.each do |product|
      ProductAttributeUpdateJob.perform_now(product)
      sleep 0.250
    end
  end
end