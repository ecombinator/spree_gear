module Spree
  class MailingRecipientsController < StoreController
    before_action :set_mailing_recipient, only: [:edit, :update]

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

    def set_mailing_recipient
      @mailing_recipient = Spree::MailingRecipient.find(params[:id])
      head 404 unless @mailing_recipient
    end

    def mailing_recipient_params
      params.require(:mailing_recipient).permit :opted_in
    end
  end
end