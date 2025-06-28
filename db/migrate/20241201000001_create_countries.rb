class CreateCountries < ActiveRecord::Migration[7.2]
  def change
    create_table :countries do |t|
      t.string :name, null: false
      t.string :code, limit: 2, null: false
      t.string :timezone

      t.timestamps
    end

    add_index :countries, :name, unique: true
    add_index :countries, :code, unique: true
  end
end
