module Spree
  module Admin
    class MailingRecipientsController < BaseController
      before_action :set_recipient, only: [:update]

      def index
        if params[:search].present?
          @recipients = MailingRecipient.where("email ILIKE ?", "%#{params[:search]}%")
        else
          @recipients = MailingRecipient.where(opted_in: true)
        end
        params[:page] ||= 1
        params[:limit] ||= 25
        @recipients = @recipients.order(:email).limit(params[:limit]).page(params[:page])
      end

      def update
        @recipient.update(mailing_recipient_params)
        render :update
      end

      def suppress

      end

      def bulk_suppress
        @recipients = MailingRecipient.from_csv(mailing_recipients_params[:csv])
        respond_to do |format|
          if @recipients.any? && @recipients.update_all(opted_in: false)
            format.html { redirect_to admin_mailing_recipients_path, notice: "Suppressed!" }
          else
            format.html { redirect_to suppress_admin_mailing_recipients_path, alert: "Did not suppress" }
          end
        end
      end

      private

      def set_recipient
        @recipient = MailingRecipient.find(params[:id])
      end

      def mailing_recipient_params
        params.require(:mailing_recipient).permit(:opted_in)
      end

      def mailing_recipients_params
        params.require(:mailing_recipients).permit(:csv, :opted_in)
      end
    end
  end
end
