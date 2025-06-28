class CreateShows < ActiveRecord::Migration[7.2]
  def change
    create_table :shows do |t|
      t.integer :tvmaze_id, null: false
      t.string :name, null: false
      t.string :show_type
      t.string :language
      t.string :status
      t.integer :runtime
      t.date :premiered
      t.date :ended
      t.string :official_site
      t.text :summary
      t.string :image_url
      t.integer :weight, default: 0
      t.decimal :rating, precision: 3, scale: 1
      t.references :network, null: true, foreign_key: true
      t.bigint :tvmaze_updated_at

      t.timestamps
    end

    add_index :shows, :tvmaze_id, unique: true
    add_index :shows, :name
    add_index :shows, :status
    add_index :shows, :premiered
    add_index :shows, :rating
    add_index :shows, :tvmaze_updated_at
  end
end
