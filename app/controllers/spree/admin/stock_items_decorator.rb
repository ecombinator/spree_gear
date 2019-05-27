Spree::Admin::StockItemsController.class_eval do
  def create
    variant = Spree::Variant.find(params[:variant_id])
    stock_location = Spree::StockLocation.find(params[:stock_location_id])

    if params[:stock_movement][:quantity].present?
      stock_location.move(variant, params[:stock_movement][:quantity].to_i)
    end

    redirect_back fallback_location: spree.stock_admin_product_url(variant.product)
  end
end
