class SaveAddresses < ActiveRecord::Migration[5.2]
  def up
    Spree::Address.all.each &:save
  end

  def down; end
end
