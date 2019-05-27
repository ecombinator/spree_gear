# frozen_string_literal: true

Spree::CheckoutController.class_eval do
  before_action :check_for_wholesaler_candidates

  private

  def check_for_wholesaler_candidates
    return unless spree_current_user.present?
    if spree_current_user.has_spree_role?("wholesaler-candidate")
      redirect_to welcome_wholesalers_path and return
    end
  end
end
