Spree::VolumePrice.class_eval do
  after_update :update_product_price_ranges

  def update_product_price_ranges
    variant&.product&.update_price_ranges
  end
end
