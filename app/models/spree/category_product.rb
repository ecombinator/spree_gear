module Spree
  class CategoryProduct < Base
    belongs_to :home_category, class_name: "Spree::Category"
    belongs_to :product, class_name: "Spree::Product"

    validates :product_id, presence: true
    validates :home_category_id, presence: true
  end
end
