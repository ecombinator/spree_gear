# frozen_string_literal: true

module Spree::Admin::UsersControllerExtensions

  def index
    Spree::User.all
    apply_state_filters
  end

  def approve
    @user = Spree::User.find params[:id]
    if @user.has_spree_role?("wholesaler_candidate")
      @user.spree_roles.find_by_name("wholesaler-candidate")&.destroy
      @user.spree_roles << Spree::Role.find_by_name("wholesaler")
    end
    @user.spree_roles << Spree::Role.find_by_name("patient")
    @user.spree_roles << Spree::Role.find_by_name("user")
    @user.save

    redirect_to :admin_users
  end

  private

  def user_params
    params.require(:user).permit(
      permitted_user_attributes + [:referred_by_id, :identification, :locked_at] |
        [spree_role_ids: [],
         ship_address_attributes: permitted_address_attributes,
         bill_address_attributes: permitted_address_attributes]
    ).tap do |p|
      # only allow superadmins to set referred_by_id
      unless spree_current_user.has_spree_role?("superadmin")
        p.delete("referred_by_id")
      end

      # only allow superadmins to update superadmin role for user
      unless spree_current_user.has_spree_role?("superadmin")
        persist_role_id p, Spree::Role.find_by_name("superadmin").id
        persist_role_id p, Spree::Role.find_by_name("sales_rep").id
      end
    end
  end

  def export
    respond_to do |format|
      format.csv
    end
  end

  def persist_role_id(p, role_id)
    return unless  p["spree_role_ids"].present?
    if @user.spree_role_ids.include?(role_id)
      p["spree_role_ids"] << role_id
    else
      p["spree_role_ids"].delete(role_id.to_s)
    end
    p
  end

  def apply_state_filters
    # defaults to these views
    unless cookies[:user_state_filter] || params[:referrer]
      if spree_current_user.has_spree_role?("superadmin")
        cookies[:user_state_filter] = "unapproved"
      else
        cookies[:user_state_filter] = "all"
      end
    end

    cookies.delete :user_state_filter if params[:user_state_filter] == "all"

    if cookies[:user_state_filter].present?
      case cookies[:user_state_filter]
      when "unapproved"
        @users = @users.unapproved.order(created_at: :asc)
      end
    end
  end
end

Spree::Admin::UsersController.class_eval do
  prepend Spree::Admin::UsersControllerExtensions
end
