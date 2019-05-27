module Spree
  class WholesalersController < UserRegistrationsController
    after_action :apply_wholesaler_candidate_role, only: [:create]
    after_action :send_new_wholesaler_email, only: [:create]

    def welcome
      if is_not_a_candidate?
        redirect_to root_path and return
      end
    end

    private

    def is_not_a_candidate?
      !spree_current_user.present? || (spree_current_user.present? &&
        !spree_current_user.has_spree_role?("wholesaler-candidate"))
    end

    def user_params
      params.require(:user).permit(
        Spree::PermittedAttributes.user_attributes + custom_permitted_attributes
      )
    end

    def custom_permitted_attributes
      [:phone, :company, :referred_by_id, :title, :name]
    end

    def apply_wholesaler_candidate_role
      @user.spree_role_ids = [Spree::Role.find_by_name("wholesaler-candidate").id]
      @user.save
    end

    def send_new_wholesaler_email
      if @user.persisted?
        Spree::WholesaleCandidatesMailer.new_wholesaler(@user).deliver_now
      end
    end

    def after_sign_up_path_for(_resource)
      welcome_wholesalers_path
    end

    def resource_class
      Spree::User
    end
  end
end
