module Spree
  class StoreCreditMailer < BaseMailer
    include ActionView::Helpers::NumberHelper

    def referral_credit_notification(store_credit)
      @store_credit = store_credit
      @user = store_credit.user
      @store = Spree::Store.find(Rails.application.config.current_store_id)
      mail(
        to: @user.email,
        from: from_address,
        subject: "You've been credited #{number_to_currency @store_credit.amount}!"
      )
    end
  end
end