Spree::FrontendHelper.module_eval do
  def has_no_reviews?(product)
    Spree::Reviews::Config[:include_unapproved_reviews] == false && product.reviews.approved.count == 0
  end
end
