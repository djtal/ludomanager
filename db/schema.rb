# encoding: UTF-8

# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20140517074550) do

  create_table "account_games", force: true do |t|
    t.integer  "game_id"
    t.integer  "account_id"
    t.datetime "created_at"
    t.text     "origin"
    t.float    "price"
    t.datetime "transdate"
    t.boolean  "shield"
    t.integer  "parties_count", default: 0
    t.boolean  "rules"
    t.boolean  "cheatsheet"
    t.integer  "edition_id"
    t.date     "last_play"
  end

  create_table "accounts", force: true do |t|
    t.string   "login"
    t.string   "email"
    t.string   "crypted_password",          limit: 40
    t.string   "salt",                      limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.boolean  "game",                                 default: true
    t.boolean  "party",                                default: true
    t.boolean  "member",                               default: true
  end

  create_table "authors", force: true do |t|
    t.string "name"
    t.string "surname"
    t.string "homepage"
    t.string "lang",     default: ""
  end

  create_table "authorships", force: true do |t|
    t.integer "author_id"
    t.integer "game_id"
  end

  create_table "editions", force: true do |t|
    t.integer  "game_id"
    t.integer  "editor_id"
    t.text     "lang"
    t.text     "name"
    t.date     "published_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "editors", force: true do |t|
    t.text     "name"
    t.text     "homepage"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "lang"
    t.string   "logo_file_name"
    t.string   "logo_content_type"
    t.integer  "logo_file_size"
    t.datetime "logo_updated_at"
    t.integer  "editions_count",    default: 0
  end

  create_table "games", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "difficulty",       default: 2
    t.integer  "min_player",       default: 1
    t.integer  "max_player"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "url"
    t.float    "average",          default: 0.0
    t.integer  "target",           default: 0
    t.integer  "time_category",    default: 0
    t.string   "box_file_name"
    t.string   "box_content_type"
    t.integer  "box_file_size"
    t.datetime "box_updated_at"
    t.integer  "base_game_id"
    t.boolean  "standalone"
  end

  create_table "parties", force: true do |t|
    t.integer  "game_id"
    t.datetime "created_at"
    t.integer  "account_id"
    t.integer  "nb_player"
  end

  create_table "taggings", force: true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context",       limit: 128
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true, using: :btree

  create_table "tags", force: true do |t|
    t.string  "name"
    t.integer "taggings_count", default: 0
  end

  add_index "tags", ["name"], name: "index_tags_on_name", unique: true, using: :btree

end
