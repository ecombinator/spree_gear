module Spree
  class MarketingMailer < BaseMailer
    layout 'mailer'

    def mass_email(mailing, recipient)
      @recipient = recipient
      @mailing = mailing
      headers["List-Unsubscribe"] = opt_out_mailing_recipient_url(@recipient.id)
      mail to: @recipient.email,
           from: @mailing.from,
           subject: @mailing.subject
    end
  end
end
