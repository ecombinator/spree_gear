module Spree
  class MailingRecipient < Base
    belongs_to :user, inverse_of: :mailing_recipient, optional: true
    validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }

    def self.from_email(email)
      existing = find_by_email(email)
      return existing if existing

      user = User.where(email: email).first
      recipient = create!(email: email, spree_user_id: user&.id, opted_in: true)
      recipient
    end

    def self.from_csv(csv_file)
      csv = CSV.parse(csv_file.read, headers: :first_row)
      key = if csv.headers.none?
              0
            elsif csv.headers.include?("address")
              "address"
            elsif csv.headers.include?("email")
              "email"
            else
              0
            end
      emails = csv.map do |row|
        email = row[key]
        return nil unless email
        email
      end.reject(&:nil?)
      where(email: emails)
    end
  end
end
