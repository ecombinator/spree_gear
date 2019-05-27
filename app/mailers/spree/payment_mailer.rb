module Spree
  class PaymentMailer < BaseMailer
    def confirm_email(payment)
      @payment = payment.respond_to?(:id) ? payment : Spree::Payment.find(payment)
      @order = Spree::Order.find(@payment.order_id)
      subject = "#{Spree::Store.current.name} #{Spree.t('payment_mailer.confirm_email.subject')} ##{@order.number}"
      mail(to: @order.email, from: from_address, subject: subject)
    end
  end
end
