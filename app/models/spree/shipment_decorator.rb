Spree::Shipment.class_eval do
  def ready?
    state != "shipped" && ["balance_due", "complete"].include?(order.state)
  end
end
