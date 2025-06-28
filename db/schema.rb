# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2024_12_01_000006) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "countries", force: :cascade do |t|
    t.string "name", null: false
    t.string "code", limit: 2, null: false
    t.string "timezone"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_countries_on_code", unique: true
    t.index ["name"], name: "index_countries_on_name", unique: true
  end

  create_table "episodes", force: :cascade do |t|
    t.integer "tvmaze_id", null: false
    t.bigint "show_id", null: false
    t.string "name", null: false
    t.integer "season", null: false
    t.integer "number", null: false
    t.string "episode_type"
    t.date "airdate"
    t.time "airtime"
    t.datetime "airstamp"
    t.integer "runtime"
    t.text "summary"
    t.string "image_url"
    t.decimal "rating", precision: 3, scale: 1
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["airdate"], name: "index_episodes_on_airdate"
    t.index ["airstamp"], name: "index_episodes_on_airstamp"
    t.index ["show_id", "season", "number"], name: "index_episodes_on_show_id_and_season_and_number", unique: true
    t.index ["show_id"], name: "index_episodes_on_show_id"
    t.index ["tvmaze_id"], name: "index_episodes_on_tvmaze_id", unique: true
  end

  create_table "genres", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_genres_on_name", unique: true
  end

  create_table "networks", force: :cascade do |t|
    t.integer "tvmaze_id", null: false
    t.string "name", null: false
    t.bigint "country_id", null: true
    t.string "official_site"
    t.string "timezone"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["country_id"], name: "index_networks_on_country_id"
    t.index ["name"], name: "index_networks_on_name"
    t.index ["tvmaze_id"], name: "index_networks_on_tvmaze_id", unique: true
  end

  create_table "show_genres", force: :cascade do |t|
    t.bigint "show_id", null: false
    t.bigint "genre_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["genre_id"], name: "index_show_genres_on_genre_id"
    t.index ["show_id", "genre_id"], name: "index_show_genres_on_show_id_and_genre_id", unique: true
    t.index ["show_id"], name: "index_show_genres_on_show_id"
  end

  create_table "shows", force: :cascade do |t|
    t.integer "tvmaze_id", null: false
    t.string "name", null: false
    t.string "show_type"
    t.string "language"
    t.string "status"
    t.integer "runtime"
    t.date "premiered"
    t.date "ended"
    t.string "official_site"
    t.text "summary"
    t.string "image_url"
    t.integer "weight", default: 0
    t.decimal "rating", precision: 3, scale: 1
    t.bigint "network_id"
    t.bigint "tvmaze_updated_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_shows_on_name"
    t.index ["network_id"], name: "index_shows_on_network_id"
    t.index ["premiered"], name: "index_shows_on_premiered"
    t.index ["rating"], name: "index_shows_on_rating"
    t.index ["status"], name: "index_shows_on_status"
    t.index ["tvmaze_id"], name: "index_shows_on_tvmaze_id", unique: true
    t.index ["tvmaze_updated_at"], name: "index_shows_on_tvmaze_updated_at"
  end

  add_foreign_key "episodes", "shows"
  add_foreign_key "networks", "countries"
  add_foreign_key "show_genres", "genres"
  add_foreign_key "show_genres", "shows"
  add_foreign_key "shows", "networks"
end
