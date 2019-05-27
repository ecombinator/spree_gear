# This migration comes from spree_gear (originally 20171215082539)
# This migration comes from spree_address_book (originally 20170405133031)
migration_superclass = if ActiveRecord::VERSION::MAJOR >= 5
  ActiveRecord::Migration[5.1]["#{ActiveRecord::VERSION::MAJOR}.#{ActiveRecord::VERSION::MINOR}"]
else
  ActiveRecord::Migration[5.1]
end

class AddMissingIndexes < migration_superclass
  def self.up
    add_index addresses_table_name, :user_id
    add_index addresses_table_name, :deleted_at
  end

  def self.down
    remove_index addresses_table_name, :user_id
    remove_index addresses_table_name, :deleted_at
  end

  private

  def self.addresses_table_name
    table_exists?('addresses') ? :addresses : :spree_addresses
  end
end
