module Spree
  module Admin
    module Orders
      CustomerDetailsController.class_eval do
        def edit
          set_order_and_billings
        end

        def update
          if @order.update_attributes(order_params)
            @order.associate_user!(@user, @order.email.blank?) unless guest_checkout?
            @order.next if @order.address?
            @order.refresh_shipment_rates(Spree::ShippingMethod::DISPLAY_ON_BACK_END)

            if @order.errors.empty?
              flash[:success] = Spree.t('customer_details_updated')
              redirect_to edit_admin_order_url(@order)
            else
              render action: :edit
            end
          else
            set_order_and_billings
            render action: :edit
          end
        end

        private

        def set_order_and_billings
          country_id = Spree::Address.default.country.id
          @order.build_bill_address(country_id: country_id) if @order.bill_address.nil?
          @order.build_ship_address(country_id: country_id) if @order.ship_address.nil?

          @order.bill_address.country_id = country_id if @order.bill_address.country.nil?
          @order.ship_address.country_id = country_id if @order.ship_address.country.nil?
        end
      end
    end
  end
end
