class CreateNetworks < ActiveRecord::Migration[7.2]
  def change
    create_table :networks do |t|
      t.integer :tvmaze_id, null: false
      t.string :name, null: false
      t.references :country, null: true, foreign_key: true
      t.string :official_site
      t.string :timezone

      t.timestamps
    end

    add_index :networks, :tvmaze_id, unique: true
    add_index :networks, :name
  end
end
