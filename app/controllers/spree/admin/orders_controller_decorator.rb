# frozen_string_literal: true

module Spree
  module Admin
    OrdersController.class_eval do
      alias_method :old_index, :index
      before_action :strip_search, only: :index

      def index
        old_index
        apply_state_filters
        limit_to_current_store

        if params[:referrer] && params[:referrer] != ""
          @orders = @orders.joins(:user).where(spree_users: { referred_by_id: params[:referrer] })
        end

        if spree_current_user.has_spree_role?("packer") || spree_current_user.has_spree_role?("shipper")
          # restricts out the unpaid if the current user is a packer or shipper
          @orders = @orders.where.not(payment_state: "paid")
        end

        rep_role = Spree::Role.find_by_name("sales_rep")
        @sales_reps = rep_role && Spree::User.named_sales_reps || User.none
      end

      def ship_batch
        shipped_order_numbers = []
        unshipped_order_numbers = []
        Shipment.joins(:order).
            where(spree_orders: { number: params[:order_ids], shipment_state: "ready"}).each do |shipment|
          if shipment.tracking.nil?
            unshipped_order_numbers << shipment.order.number
          else
            shipment.ship!
            shipped_order_numbers << shipment.order.number
          end
        end

        flash[:notice] = "Shipped orders #{shipped_order_numbers.to_sentence}" if shipped_order_numbers.any?
        flash[:error] = "Orders #{unshipped_order_numbers.to_sentence} don't have tracking numbers." if unshipped_order_numbers.any?
        redirect_to admin_orders_path
      end

      private

      def limit_to_current_store
        current_store_id = ENV["CURRENT_STORE_ID"]
        return unless current_store_id
        @orders = @orders.where(store_id: [current_store_id.to_i, nil])
      end

      def apply_state_filters
        # defaults to these views
        unless cookies[:order_state_filter] || params[:referrer]
          if spree_current_user.has_spree_role?("packer")
            cookies[:order_state_filter] = "paid"
          elsif spree_current_user.has_spree_role?("billing_manager")
            cookies[:order_state_filter] = "not_paid"
          elsif spree_current_user.has_spree_role?("shipper") && Rails.application.config.ready_to_ship
            cookies[:order_state_filter] = "ready"
          end
        end

        if params[:order_state_filter] == "all" ||
          (!Rails.application.config.ready_to_ship && params[:order_state_filter] == "ready")
          cookies.delete :order_state_filter
        end

        if cookies[:order_state_filter].present?
          case cookies[:order_state_filter]
          when "not_paid"
            @orders = @orders.where.not(payment_state: ["paid", "void"])
          when "paid"
            @orders = @orders.where(payment_state: "paid", approved_at: nil).where.not(shipment_state: "shipped")
          when "ready"
            @orders = @orders.where(shipment_state: "ready").where.not(approved_at: nil)
          when "shipped"
            @orders = @orders.where(shipment_state: "shipped")
          end
        end
      end

      def strip_search
        return unless params[:q] && params[:q][:number_or_email_cont].present?
        params[:q][:number_or_email_cont] = params[:q][:number_or_email_cont].strip
      end
    end
  end
end

class AbilityDecorator
  include CanCan::Ability
  def initialize(user)
    if user.respond_to?(:has_spree_role?) && user.has_spree_role?("packer") ||
      user.has_spree_role?("shipper") || user.has_spree_role?("billing_manager")
      can [:admin, :index, :show], Spree::Order

      can [:edit], Spree::Order if user.has_spree_role?("billing_manager")

    end
  end
end

Spree::Ability.register_ability(AbilityDecorator)
