module Spree
  StockItem.instance_eval do
    after_update :update_stock_statuses, if: :count_on_hand_changed?
    after_update :update_product_availability
    before_save :disable_backordering, if: -> { Rails.application.config.disable_backordering }
  end

  StockItem.class_eval do
    def disable_backordering
      self.assign_attributes backorderable: false
    end

    def update_product_availability
      variant.product.update_availability_status
    end

    def update_stock_statuses
      variant.update_stock_status
    end
  end
end
