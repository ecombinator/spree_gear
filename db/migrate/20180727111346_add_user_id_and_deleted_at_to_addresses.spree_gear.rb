# This migration comes from spree_gear (originally 20171215082538)
# This migration comes from spree_address_book (originally 20110302102208)
migration_superclass = if ActiveRecord::VERSION::MAJOR >= 5
  ActiveRecord::Migration[5.1]["#{ActiveRecord::VERSION::MAJOR}.#{ActiveRecord::VERSION::MINOR}"]
else
  ActiveRecord::Migration[5.1]
end

class AddUserIdAndDeletedAtToAddresses < migration_superclass
  def self.up
    change_table addresses_table_name do |t|
      t.integer :user_id
      t.datetime :deleted_at
    end
  end

  def self.down
    change_table addresses_table_name do |t|
      t.remove :deleted_at
      t.remove :user_id
    end
  end

  private

  def self.addresses_table_name
    table_exists?('addresses') ? :addresses : :spree_addresses
  end
end
