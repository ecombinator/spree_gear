class Spree::HomeCategoriesController < Spree::StoreController
  before_action :set_body_id
  before_action :set_home_categories
  before_action :set_slider

  def index
  end

  private

  def set_body_id
    @body_id = "home-index"
  end

  def set_home_categories
    @home_categories = Spree::HomeCategory.by_order
  end

  def set_slider
    @slider = Spree::Slider.active.first
  end

end
