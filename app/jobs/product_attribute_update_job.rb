
class ProductAttributeUpdateJob < ApplicationJob
  def perform(product)
    product.update_brand_and_main_category
    product.update_availability_status
    product.update_price_ranges
    product.update_discount_attributes
  end
end