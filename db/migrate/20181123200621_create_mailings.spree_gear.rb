class CreateMailings < ActiveRecord::Migration[5.2]
  def change
    create_table :spree_mailings do |t|
      t.string :name
      t.string :from
      t.string :subject

      t.timestamps
    end
  end
end
