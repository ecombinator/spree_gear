module Spree
  class Notification < Base
    belongs_to :notifiable, polymorphic: true
    belongs_to :user

    validates :mailer_action, presence: true

    after_create :auto_deliver

    def deliver_mailer(mailer_args = [])
      raise unless mailer_args.is_a? Array
      mailer_arr = mailer_action.split(".")
      return unless mailer_arr.length > 1
      Object.const_get(mailer_arr.first).send(mailer_arr.last, *mailer_args).deliver_later
    end


    private

    def auto_deliver
      return unless auto_send

      mailer_arr = mailer_action.split(".")
      return unless mailer_arr.length == 2
      mailer_class, mailer_target_action = mailer_arr
      Object.const_get(mailer_class).send(mailer_target_action, *[user.id, notifiable.id]).deliver_later
    end
  end
end
