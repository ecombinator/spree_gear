module Spree
  class Slider < Base
    validates :title, presence: true
    has_many :slides, dependent: :destroy

    scope :active, (-> { where active: true })
    accepts_nested_attributes_for :slides, allow_destroy: true

    def activate
      Spree::Slider.active.map(&:deactivate)
      update_attributes(active: true)
    end

    def deactivate
      update_attributes(active: false)
    end
  end
end
