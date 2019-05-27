module Spree
  class MailingRecipient < Base
    belongs_to :user, inverse_of: :mailing_recipient, optional: true
    validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }

    def self.from_email(email)
      existing = find_by_email(email)
      return existing if existing

      user = User.where(email: email).first
      puts "Existing user is #{user.inspect}"
      recipient = create!(email: email, spree_user_id: user&.id, opted_in: true)
      recipient
    end
  end
end
