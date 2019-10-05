module Spree
  class MailingRecipientsController < StoreController
    before_action :set_mailing_recipient, only: [:edit, :update, :opt_out, :opt_in]
    before_action :set_mailing_recipient_by_email, only: [:create]

    def create
      @mailing_recipient ||= Spree::MailingRecipient.new(mailing_recipient_params)
      respond_to do |format|
        if @mailing_recipient.save
          session[:signed_up] = true
          format.js { render status: 200 }
        else
          format.js { head 422 }
        end
      end
    end

    def opt_out
      params["mailing_recipient"] = {
          "opted_in": false
      }
      update
    end

    def opt_in
      params["mailing_recipient"] = {
          "opted_in": true
      }
      update
    end

    def edit; end

    def update
      respond_to do |format|
        if @mailing_recipient.update(mailing_recipient_params)
          message = @mailing_recipient.opted_in ? "Hope to see you during our next promotion!" : "Sorry to see you go!"
          format.html { redirect_to edit_mailing_recipient_url, notice: "Saved. #{message}" }
          format.json { render :edit, status: :created, location: @mailing_recipient }
        else
          format.html { render :new }
          format.json { render json: @mailing_recipient.errors, status: :unprocessable_entity }
        end
      end
    end

    private

    def set_mailing_recipient_by_email
      return unless params.has_key?(:mailing_recipient)
      @mailing_recipient = Spree::MailingRecipient.where(email: params[:mailing_recipient][:email]).first
      head 404 unless @mailing_recipient
    end

    def set_mailing_recipient
      @mailing_recipient = Spree::MailingRecipient.find(params[:id])
    end

    def mailing_recipient_params
      params.require(:mailing_recipient).permit :opted_in, :email
    end
  end
end