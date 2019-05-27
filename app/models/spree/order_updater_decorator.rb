Spree::OrderUpdater.class_eval do
  def update_item_total
    order.item_total = line_items.map do |line_item|
      line_item.price * line_item.quantity
    end.sum

    update_order_total
  end
end
