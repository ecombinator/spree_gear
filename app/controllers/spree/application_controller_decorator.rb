# frozen_string_literal: true

module Spree
  ApplicationController.class_eval do
    before_action :prepare_exception_notifier

    before_action :confirm_identification
    before_action :remove_corrupted_order
    before_action :store_referral_token, if: -> { !spree_current_user && params["referral_token"].present? }

    def store_referral_token
      referrer = Spree::User.where(referral_token: params["referral_token"]).first
      return unless referrer
      session["referred_by_id"] = referrer.id
      redirect_to root_url
    end

    def confirm_identification
      return unless Rails.application.config.require_documentation
      return if whitelisted_controllers.include?(controller_name)
      return unless defined? try_spree_current_user
      return if self.class.parent == Admin
      user = try_spree_current_user
      return if !user || user.new_record? || user.wholesaler?
      if ENV.fetch("REQUIRE_USER_APPROVAL", "false") == "true" && user.identification.present? && !user.patient?
        flash[:notice] = "Please wait for your identification to be approved"
        redirect_to "#{account_path}#account-details" and return
      end

      redirect_to "#{account_path}#account-details" and return unless user.identification.present?
    end

    def remove_corrupted_order
      return unless defined? simple_current_order
      order = simple_current_order
      return unless order
      order.destroy! if order.line_items.select{ |li| li.variant.nil? }.any?

    end

    private

    def prepare_exception_notifier
      request.env["exception_notifier.exception_data"] = {
          current_user: spree_current_user
      }
    end

    def whitelisted_controllers
      ["user_sessions", "users", "masquerades", "user_registrations", "errors", "wholesalers"]
    end

  end
end
