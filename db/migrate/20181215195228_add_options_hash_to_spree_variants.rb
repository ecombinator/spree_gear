class AddOptionsHashToSpreeVariants < ActiveRecord::Migration[5.2]
  def up
    add_column :spree_variants, :options_hash, :string
    Spree::Variant.all.map &:update_options_hash
    add_index :spree_variants, [ :options_hash ]
  end

  def down
    remove_column :spree_variants
  end
end
