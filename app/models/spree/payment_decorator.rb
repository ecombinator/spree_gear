Spree::Payment.class_eval do
  after_save :deliver_payment_confirmation_email, if: [:state_changed?, :completed?]
  before_save :update_completed_at

  def deliver_payment_confirmation_email
    Spree::PaymentMailer.confirm_email(id).deliver
  end

  private

  def update_completed_at
    return unless completed? && !completed_at.present?
    self.completed_at = Time.now
  end
end
