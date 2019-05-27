class AddCompletedAtToSpreePayments < ActiveRecord::Migration[5.2]
  def up
    add_column :spree_payments, :completed_at, :datetime
    Spree::Payment.reset_column_information
    Spree::Payment.completed.each do |payment|
      next if payment.completed_at.present?
      payment.update_attributes(completed_at: payment.updated_at)
    end
  end

  def down
    remove_column :spree_payments, :completed_at
  end
end
