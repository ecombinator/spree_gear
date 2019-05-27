module Spree
  module Admin
    InvoiceController.class_eval do
      def index
        params[:template] = "invoice" unless params[:template].present?
        instance_variable_set('@' + params[:template], true)
        @orders = Spree::Order.where(number: params[:order_ids]).order(:id)
        render "#{params[:template]}_index", layout: false
      end

      def email_invoices
        text = "PAYMENTS_EMAIL not set, please contact admin"
        if ENV.fetch('PAYMENTS_EMAIL').present?
          Spree::OrderMailer.invoice(params[:order_ids]).deliver_later
          text = "Invoices #{params[:order_ids].map{|g| g}} sent to #{ENV.fetch('PAYMENTS_EMAIL')}"
        end
        render plain: text
      end
    end
  end
end
