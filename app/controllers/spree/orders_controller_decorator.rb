Spree::OrdersController.class_eval do
  def referred
    @users = spree_current_user.referred_users
    @orders = Spree::Order.complete.where(user_id: @users).order(completed_at: :desc)
  end
end
