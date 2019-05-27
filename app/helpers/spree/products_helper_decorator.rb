Spree::ProductsHelper.module_eval do
  def product_short_description(product)
    description = product.short_description
    description.blank? ? "" : raw(description.to_s.gsub(/(.*?)\r?\n\r?\n/m, '<p>\1</p>'))
  end

  def cache_key_for_products
    count = @products.count
    max_updated_at = (@products.maximum(:updated_at) || Date.today).to_s(:number)
    taxon = @taxon&.permalink || "all"
    products_cache_keys = "spree/products/#{taxon}-#{params[:page]}-#{max_updated_at}-#{count}-#{params[:sorting]}"
    (common_product_cache_keys + [products_cache_keys]).compact.join("/")
  end

  def sorting_attribute
    return unless params.has_key?(:sorting)
    params[:sorting].gsub(/[a-z_]+_by_/, "").to_sym
  end
end
