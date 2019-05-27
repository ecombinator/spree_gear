Spree::Price.class_eval do
  after_update :update_master_price_ranges

  def update_master_price_ranges
    variant.product.update_price_ranges
  end
end
