# This migration comes from spree_gear (originally 20170223012170)
# This migration comes from spree_gateway (originally 20131008221012)
class UpdatePaypalPaymentMethodType < ActiveRecord::Migration[5.1]
  def up
    Spree::PaymentMethod.where(:type => "Spree::Gateway::PayPal").update_all(:type => "Spree::Gateway::PayPalGateway")
  end

  def down
    Spree::PaymentMethod.where(:type => "Spree::Gateway::PayPalGateway").update_all(:type => "Spree::Gateway::PayPal")
  end
end
