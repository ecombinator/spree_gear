class CreateMailingSections < ActiveRecord::Migration[5.2]
  def up
    create_table :spree_mailing_sections do |t|
      t.references :spree_mailing, foreign_key: true
      t.string :url

      t.timestamps
    end
    add_attachment :spree_mailing_sections, :image
  end

  def down
    drop_table :spree_mailing_sections
  end
end
