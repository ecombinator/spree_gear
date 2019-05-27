module Spree
  class HomeCategory < Base
    validates :title, presence: true
    after_create :configure_order

    has_many :category_products,
             foreign_key: "home_category_id",
             dependent: :destroy

    has_many :products, through: :category_products, source: :product

    def self.latest_order
      where.not(order: nil).order(order: :desc).first.order
    end

    def self.by_order
      where.not(order: nil).order(order: :asc)
    end

    private

    def configure_order
      if Spree::HomeCategory.count == 1
        self.update_attributes(order: 1)
      else
        order_line = Spree::HomeCategory.latest_order
        self.update_attributes(order: order_line + 1)
      end
    end
  end
end
