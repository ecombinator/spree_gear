class MailingJob < ApplicationJob
  queue_as :default

  def perform(*args)
    @mailing = Spree::Mailing.find(args[0])
    recipients = []
    recipients += user_recipients if @mailing.deliver_to_users
    recipients += Spree::MailingRecipient.where(spree_user_id: nil) if @mailing.deliver_to_non_users
    recipients += csv_recipients if @mailing&.csv&.path
    @mailing.send_to! recipients.uniq
  end

  def clean_up
    mailing.csv.clear
    mailing.save

  end

  def csv_emails
    return [] unless @mailing&.csv&.path
    csv = File.open(@mailing.csv.path).read
    csv.gsub!(/\r\n?/, "\n")
    csv.each_line.map { |e| e.to_s.strip }.reject(&:blank?)
  end

  def csv_recipients
    csv_emails.map do |email|
      Spree::MailingRecipient.from_email(email)
    end
  end

  def user_recipients
    Spree::User.all.map do |user|
      Spree::MailingRecipient.from_email(user.email)
    end
  end
end
