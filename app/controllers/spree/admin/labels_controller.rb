module Spree
  module Admin
    class LabelsController < BaseController
      before_action :set_shipment, only: [:show, :print]

      def index
        @shipments = Shipment.where(number: params[:shipment_numbers]).order(:order_id)
        labels = ShippingLabel.new(@shipments).render

        send_data labels,
                  filename: "label_#{Time.now.to_i}.pdf",
                  type: "application/pdf", disposition: "inline"
      end

      def show
        labels = ShippingLabel.new([@shipment]).render

        send_data labels,
                  filename: "label_#{@shipment.number}.pdf",
                  type: "application/pdf", disposition: "inline"
      end

      def print
        render layout: false
      end

      def print_batch
        @shipment_numbers = Shipment.joins(:order).
            where(spree_orders: { number: params[:order_ids]}).map(&:number)

        render layout: false
      end

      private

      def set_shipment
        @shipment = Shipment.find_by_number(params[:shipment_number]) if params[:shipment_number]
      end
    end
  end
end
