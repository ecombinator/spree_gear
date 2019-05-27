module Spree
  Spree::UserMailer.class_eval do
    def approval_email(user)
      recipient = Rails.application.config.contact_notification_email
      @user = user
      mail(
          to: recipient,
          from: from_address,
          subject: "New user registered #{@user.email}"
      )
    end

    def approval_granted_email(user)
      @user = user
      @store = Spree::Store.find(Rails.application.config.current_store_id)
      mail(
          to: user,
          from: from_address,
          subject: "Welcome to #{@store.name}!"
      )
    end
  end
end
