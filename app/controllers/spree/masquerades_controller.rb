module Spree
  class MasqueradesController < StoreController
    before_action :is_logged_in?
    before_action :set_user, only: [:new, :approve]
    before_action :require_sales_or_admin, only: [:index, :new]


    def index
      @users = spree_current_user.referred_users.order(:email)
    end

    def new
      session[:admin_id] = try_spree_current_user.id
      sign_in @user
      redirect_to root_path
    end

    def destroy
      masquerade_id = try_spree_current_user.id
      user = User.find_by_id session[:admin_id]
      session[:admin_id] = nil
      sign_in user
      redirect_to user.admin? ? edit_admin_user_path(masquerade_id) : masquerades_path
    end

    def approve
      @user.spree_roles << Spree::Role.find_by_name("patient")
      redirect_to masquerades_path
    end

    private

    def is_logged_in?
      redirect_to root_path and return unless try_spree_current_user.present?
    end

    def set_user
      @user = User.find_by_id params[:id]
      @user ||= User.find_by_id params[:user_id]
    end

    def require_sales_or_admin
      if !try_spree_current_user &&
         !try_spree_current_user.admin? &&
         !(try_spree_current_user.sales_rep? && try_spree_current_user.id == @user.referred_by_id)

        redirect_to root_path
      end
    end
  end
end
