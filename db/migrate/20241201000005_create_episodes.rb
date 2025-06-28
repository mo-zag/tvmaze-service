class CreateEpisodes < ActiveRecord::Migration[7.2]
  def change
    create_table :episodes do |t|
      t.integer :tvmaze_id, null: false
      t.references :show, null: false, foreign_key: true
      t.string :name, null: false
      t.integer :season, null: false
      t.integer :number, null: false
      t.string :episode_type
      t.date :airdate
      t.time :airtime
      t.datetime :airstamp
      t.integer :runtime
      t.text :summary
      t.string :image_url
      t.decimal :rating, precision: 3, scale: 1

      t.timestamps
    end

    add_index :episodes, :tvmaze_id, unique: true
    add_index :episodes, :airdate
    add_index :episodes, :airstamp
    add_index :episodes, [ :show_id, :season, :number ], unique: true
  end
end
