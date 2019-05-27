module Spree
  Order.class_eval do
    before_validation(on: :create) do
      self.number = Spree::Core::NumberGenerator.new(prefix: 'R', length: 6).send(:generate_permalink, Spree::Order)
      self.store_id ||= Rails.application.config.current_store_id
    end

    after_save :apply_wholesaler_discounts
    has_many :notifications, as: :notifiable

    scope :paid, -> { where(payment_state: ["paid", "credit_owed"]) }
    scope :by_product_category_name, -> (category_name) { includes(products: :taxons).where("lower(spree_taxons.name) = ?", category_name.downcase) }
    scope :balance_due_before, (->(selected_date) { where("? > start_bill_due_at", selected_date) })

    # Searches for completed orders but unpaid by customer for more than 48 hours
    scope :overdue, -> (time = 48.hours.ago){
      where(state: "complete", payment_state: "balance_due").where("? > completed_at", time)
    }

    def public_comments
      comments.joins(:comment_type).where(spree_comment_types: { name: "Public" })
    end

    def select_default_shipping
      create_proposed_shipments
      shipments.find_each &:update_amounts
      update_totals
    end

    def payment_password
      "spree_gear#{number.to_s.last(3)}"
    end

    def apply_wholesaler_discounts
      return if complete?
      return unless ENV["WHOLESALE_COUPON"]

      if coupon_code.nil?
        if wholesale?
          self.coupon_code = ENV["WHOLESALE_COUPON"].downcase.strip
          Spree::PromotionHandler::Coupon.new(self).apply
        end
      elsif user && (coupon_code == ENV["WHOLESALE_COUPON"].downcase.strip) && !user.wholesaler?
        user.role_users << RoleUser.create(role: Role.find_by_name("wholesaler"))
      end
    end

    def warn_overdue
      return if self.notifications.where(mailer_action: "Spree::OrderMailer.overdue_warning", user: self.user).any?
      warning_notification = self.notifications.create(mailer_action: "Spree::OrderMailer.overdue_warning", user: self.user)
      warning_notification.deliver_mailer([self.id])
    end

    def cancel_overdue_and_notify!
      self.cancel!
      self.update_with_updater!
      Spree::OrderMailer.overdue_canceled_email(self).deliver_later
    end

    def wholesale?
      user&.wholesaler?
    end

    def update_from_params_with_flash(params, permitted_params, request_env = {})
      success = false
      @updating_params = params
      run_callbacks :updating_from_params do
        # Set existing card after setting permitted parameters because
        # rails would slice parameters containg ruby objects, apparently
        existing_card_id = @updating_params[:order] ? @updating_params[:order].delete(:existing_card) : nil

        attributes = if @updating_params[:order]
                       @updating_params[:order].permit(permitted_params).delete_if { |_k, v| v.nil? }
                     else
                       {}
                     end

        if existing_card_id.present?
          credit_card = CreditCard.find existing_card_id
          if credit_card.user_id != user_id || credit_card.user_id.blank?
            raise Core::GatewayError, Spree.t(:invalid_credit_card)
          end

          credit_card.verification_value = params[:cvc_confirm] if params[:cvc_confirm].present?

          attributes[:payments_attributes].first[:source] = credit_card
          attributes[:payments_attributes].first[:payment_method_id] = credit_card.payment_method_id
          attributes[:payments_attributes].first.delete :source_attributes
        end

        if attributes[:payments_attributes]
          attributes[:payments_attributes].first[:request_env] = request_env
        end
        success = update_attributes(attributes)
        set_shipments_cost if shipments.any?
      end

      @updating_params = nil
      [success, self.errors.present? ? self.errors.full_messages.join("\n") : false]
    end
  end
end
