module Spree
  module Admin
    PaymentsController.class_eval do
      def create
        invoke_callbacks(:create, :before)

        @payment ||= @order.payments.build(object_params)
        if @payment.payment_method.source_required? && params[:card].present? and params[:card] != 'new'
          @payment.source = @payment.payment_method.payment_source_class.find_by_id(params[:card])
        end
        if params[:manual_payment].present? && params[:payment][:source_id].present?
          @payment.source = @payment.payment_method.payment_source_class.find_by_id(params[:payment][:source_id])
        end

        begin
          if @payment.save
            invoke_callbacks(:create, :after)
            # Transition order as far as it will go.
            while @order.next; end
            # If "@order.next" didn't trigger payment processing already (e.g. if the order was
            # already complete) then trigger it manually now
            @payment.process! if @order.completed? && @payment.checkout?
            flash[:success] = flash_message_for(@payment, :successfully_created)
            redirect_to admin_order_payments_path(@order)
          else
            invoke_callbacks(:create, :fails)
            flash[:error] = Spree.t(:payment_could_not_be_created)
            render :new
          end
        rescue Spree::Core::GatewayError => e
          invoke_callbacks(:create, :fails)
          flash[:error] = "#{e.message}"
          redirect_to new_admin_order_payment_path(@order)
        end
      end
    end
  end
end
