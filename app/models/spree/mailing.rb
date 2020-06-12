module Spree
  class Mailing < Base
    has_many :sections, class_name: "Spree::MailingSection", foreign_key: :spree_mailing_id

    has_attached_file :csv
    validates_attachment_content_type :csv, :content_type => ["text/csv", "application/vnd.ms-excel", "text/plain"]

    attr_accessor :deliver_now
    after_update_commit :deliver, if: :deliver_now

    def send_to!(recipients)
      reset_counts!(recipients.length)
      recipients.each do |recipient|
        next unless recipient.opted_in
        Spree::MarketingMailer.mass_email(self, recipient).deliver_now!
        update_column :sent_emails_count, sent_emails_count + 1
      rescue => error
        update_column :failed_emails_count, failed_emails_count + 1
        raise error if Rails.env.development?
      end
    end

    private

    def deliver
      MailingJob.perform_later(id)
      self.deliver_now = false
    end

    def reset_counts!(new_submitted_count = 0)
      update_columns submitted_emails_count: new_submitted_count,
                     failed_emails_count: 0,
                     sent_emails_count: 0
    end
  end
end
