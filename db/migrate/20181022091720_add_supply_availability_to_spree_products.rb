class AddSupplyAvailabilityToSpreeProducts < ActiveRecord::Migration[5.2]
  def up
    add_column :spree_products, :supply_available, :boolean, index: true

    Spree::Product.all.each do |product|
      puts "updates stock availability of ##{product.id}"
      product.update_availability_status
    end
  end

  def down
    remove_column :spree_products, :supply_available, :boolean, index: true
  end
end
