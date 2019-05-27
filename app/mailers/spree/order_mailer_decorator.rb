module Spree
  OrderMailer.class_eval do
    add_template_helper(Spree::Admin::InvoiceHelper)
    add_template_helper(SpreeGear::Base::ViewHelpers::Products)

    def overdue_warning(order, deadline = Spree.t('order_mailer.overdue_warning.deadline'))
      @order = order.respond_to?(:id) ? order : Spree::Order.find(order)
      @deadline = deadline
      subject = "#{Spree::Store.current.name} #{Spree.t('order_mailer.overdue_warning.subject')} ##{@order.number}"
      mail(to: @order.email, from: from_address, subject: subject)
    end

    def overdue_canceled_email(order, deadline = Spree.t('order_mailer.overdue_canceled_email.deadline'))
      @order = order.respond_to?(:id) ? order : Spree::Order.find(order)
      @deadline = deadline
      subject = "#{Spree::Store.current.name} #{Spree.t('order_mailer.overdue_canceled_email.subject')} ##{@order.number}"
      mail(to: @order.email, from: from_address, subject: subject)
    end

    def invoice(order_ids = [])
      @template = "invoice"
      instance_variable_set('@' + @template, true)
      @orders = Spree::Order.where(number: order_ids).order(:id)
      mail(to: ENV.fetch("PAYMENTS_EMAIL", "info@test.com"), from: from_address, subject: "Invoice")
    end

    # Overrides spree method
    def confirm_email(order, resend = false)
      @order = order.respond_to?(:id) ? order : Spree::Order.find(order)
      subject = (resend ? "[#{Spree.t(:resend).upcase}] " : '')
      subject += "#{Spree::Store.current.name} #{Spree.t('order_mailer.confirm_email.subject')} ##{@order.number}"
      cc = ENV.fetch("PAYMENTS_EMAIL", "info@test.com")
      mail(to: @order.email, cc: cc,from: from_address, subject: subject)
    end
  end
end
