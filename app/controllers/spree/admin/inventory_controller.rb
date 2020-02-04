# frozen_string_literal: true

module Spree
  module Admin
    class InventoryController < BaseController
      before_action :set_variant, only: [:show, :adjust]
      before_action :filter_by_category, only: :index
      before_action :filter_by_availability, only: :index

      def index
        @variants = @variants.order("spree_products.name, options_hash").reject { |v| v.is_master? && v.product.has_variants? }
      end

      def adjust
        quantity = params[:adjustment].to_i - @variant.total_on_hand
        location.restock @variant, quantity
        flash[:success] = "Inventory adjusted!"
#      rescue StandardError => e
#        flash[:error] = "Could not restock this item"
      ensure
        render "adjust.js"
      end

      def variants
        @variants = Spree::Variant.joins(:product).includes(:option_values)
        if params[:search]
          @variants = @variants.where("spree_products.name LIKE ? OR spree_variants.sku LIKE ?",
                                      "%#{params[:search]}%", "%#{params[:search]}%")
        end
      end

      private

      def set_variant
        @variant = Spree::Variant.find(params[:variant_id])
      end

      def location
        @location ||= if params[:id]
                        Spree::StockLocation.find(params[:id])
                      else
                        Spree::StockLocation.first
                      end
        @location ||= Spree::StockLocation.first
      end

      def filter_by_availability
        if params[:availability] == "discontinued"
          @variants = @variants.not_deleted.discontinued_products
        elsif params[:availability] == "out_of_stock"
          @variants = @variants.with_currently_active_product
                          .where("quantity_sold_last_week > 0")
                          .where(spree_stock_items: { count_on_hand: 0 })
        elsif params[:availability] == "not_yet_available"
          @variants = @variants.with_not_yet_active_product
        else
          params[:availability] = "available"
          @variants = @variants.with_currently_active_product
        end
        @variants = @variants.includes(:option_values).includes(:stock_items).
          order("#{Spree::Product.quoted_table_name}.name, #{Spree::Variant.quoted_table_name}.id")
      end

      def filter_by_category
        if params[:category].present?
          @variants = Spree::Variant.by_category_name(params[:category])
        else
          @variants = Spree::Variant
        end
      end
    end
  end
end
# class InvDecorator
#   include CanCan::Ability
#   def initialize(user)
#     if user.respond_to?(:has_spree_role?) && user.has_spree_role?('packer') || user.has_spree_role?('shipper') || user.has_spree_role?('billing_manager')
#       can [:admin, :index], Spree::StockLocation
#     end
#   end
# end
#
# Spree::Ability.register_ability(InvDecorator)
