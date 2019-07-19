
Spree::UserRegistrationsController.class_eval do
  before_action :set_user_referred_by_id,
                if: -> { params["spree_user"].present? && session["referred_by_id"].present? }, only: [:create]

  def set_user_referred_by_id
    params["spree_user"]["referred_by_id"] = session["referred_by_id"]
  end
end
