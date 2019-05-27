# This migration comes from spree_gear (originally 20170419200447)
class AddPatientFieldsToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :spree_users, :condition, :string
    add_column :spree_users, :proof_of_condition_file_name, :string
    add_column :spree_users, :proof_of_condition_content_type, :string
    add_column :spree_users, :proof_of_condition_file_size, :integer
    add_column :spree_users, :proof_of_condition_fingerprint, :string
  end
end
