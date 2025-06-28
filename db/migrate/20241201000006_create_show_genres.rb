class CreateShowGenres < ActiveRecord::Migration[7.2]
  def change
    create_table :show_genres do |t|
      t.references :show, null: false, foreign_key: true
      t.references :genre, null: false, foreign_key: true

      t.timestamps
    end

    add_index :show_genres, [ :show_id, :genre_id ], unique: true
  end
end
