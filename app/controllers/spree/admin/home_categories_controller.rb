# frozen_string_literal: true

module Spree
  module Admin
    class HomeCategoriesController < ResourceController
      before_action :set_category, only: [:edit, :update, :destroy]
      before_action :set_category_params, only: [:create]

      def create
        if @home_category.save
          if params[:category_product].present?
            params[:category_product].each do |product_id|
              unless @home_category.products.where(id: product_id).any?
                @home_category.category_products.create(product: Spree::Product.find(product_id))
              end
            end
          end
          flash_and_redirect(:info, "Sucessfuly saved!")
        else
          flash_and_redirect(:danger, "There were errors")
        end
      end

      def update
        if @home_category.update_attributes(category_params)
          if params[:category_product].present?
            params[:category_product].each do |product_id|
              unless @home_category.products.where(id: product_id).any?
                @home_category.category_products.create(product: Spree::Product.find(product_id))
              end
            end
          end
          redirect_to edit_admin_home_category_path(@home_category)
        else
          render "edit"
        end
      end

      def edit; end

      def index
        @new_category = Spree::HomeCategory.new
      end

      def update_list
        JSON.parse(params[:new_positions]).each do |position|
          # position[1] is the ID, while position[0] is the order
          if category = Spree::HomeCategory.find_by(id: position[1])
            category.update_attributes(order: position[0])
          end
        end
        respond_to do |format|
          format.html do
            flash_and_redirect(:info, "Updated list")
          end
          format.js {}
        end
      end

      def destroy
        @home_category.destroy
        respond_to do |format|
          format.html do
            flash_and_redirect(:info, "destroyed category")
          end
          format.js {}
        end
      end

      def search_products
        if params[:specific_name] == "true"
          @products = Spree::Product.where(name: params[:keywords]).limit(10)
        else
          @searcher = build_searcher(params.merge(include_images: true, per_page: 10))
          @products = @searcher.retrieve_products
          @products = @products.includes(:possible_promotions) if @products.respond_to?(:includes)
          @products = @products.sold_to try_spree_current_user
        end
        respond_to do |format|
          format.js {}
        end
      end

      private

      def set_category
        @home_category = Spree::HomeCategory.find(params[:id])
      end

      def set_category_params
        @home_category = Spree::HomeCategory.new(category_params)
      end

      def category_params
        params.require(:home_category).permit(:title)
      end

      def flash_and_redirect(alert, message)
        flash[alert] = message
        redirect_to(admin_home_categories_path) && return
      end
    end
  end
end
