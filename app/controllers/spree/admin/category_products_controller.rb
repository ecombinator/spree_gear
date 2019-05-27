# frozen_string_literal: true

module Spree
  module Admin
    class CategoryProductsController < ResourceController
      def initiate
        category = Spree::HomeCategory.find(params[:home_category_id]).category_products.find_by(product_id: params[:product_id])
        @name = category.product.name
        category.destroy
        respond_to do |format|
          format.js {}
        end
      end
    end
  end
end
