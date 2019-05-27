module Spree
  class MarketingMailer < BaseMailer
    layout 'mailer'

    def mass_email(mailing, recipient)
      @recipient = recipient
      @mailing = mailing
      mail to: @recipient.email,
           from: @mailing.from,
           subject: @mailing.subject
    end
  end
end
