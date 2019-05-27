module Spree
  class WholesaleCandidatesMailer < BaseMailer
    def new_wholesaler(user)
      @user = user

      mail(
          to: Rails.application.config.contact_notification_email,
          from: from_address,
          subject: "New wholesaler candidate"
      )
    end
  end
end
