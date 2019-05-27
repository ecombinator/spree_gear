class AddArchivedToMailings < ActiveRecord::Migration[5.2]
  def change
    add_column :spree_mailings, :archived, :boolean, default: false
  end
end
