# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20081115135948) do

  create_table "account_games", :force => true do |t|
    t.integer  "game_id",       :limit => 11
    t.integer  "account_id",    :limit => 11
    t.datetime "created_at"
    t.text     "origin"
    t.float    "price"
    t.datetime "transdate"
    t.boolean  "shield"
    t.integer  "parties_count", :limit => 11, :default => 0
    t.boolean  "rules"
    t.boolean  "cheatsheet"
    t.integer  "edition_id"
    t.string   "status"
  end

  create_table "accounts", :force => true do |t|
    t.string   "login"
    t.string   "email"
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
  end

  create_table "assets", :force => true do |t|
    t.string   "content_type"
    t.string   "filename"
    t.integer  "size",            :limit => 11
    t.integer  "width",           :limit => 11
    t.integer  "height",          :limit => 11
    t.integer  "attachable_id"
    t.string   "attachable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "authors", :force => true do |t|
    t.string "name"
    t.string "surname"
    t.string "homepage"
  end

  create_table "authorships", :force => true do |t|
    t.integer "author_id", :limit => 11
    t.integer "game_id",   :limit => 11
  end

  create_table "editions", :force => true do |t|
    t.integer  "game_id"
    t.integer  "editor_id"
    t.text     "lang"
    t.text     "name"
    t.date     "published_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "editors", :force => true do |t|
    t.text     "name"
    t.text     "homepage"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "game_photos", :force => true do |t|
    t.string  "content_type"
    t.string  "filename"
    t.integer "size",         :limit => 11
    t.integer "parent_id",    :limit => 11
    t.string  "thumbnail"
    t.integer "width",        :limit => 11
    t.integer "height",       :limit => 11
    t.integer "game_id",      :limit => 11
  end

  create_table "games", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "difficulty",    :limit => 11, :default => 2
    t.integer  "min_player",    :limit => 11, :default => 1
    t.integer  "max_player",    :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "url"
    t.float    "average",                     :default => 0.0
    t.integer  "target",                      :default => 0
    t.integer  "time_category",               :default => 0
  end

  create_table "members", :force => true do |t|
    t.text     "name"
    t.text     "nickname"
    t.integer  "account_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "email"
  end

  create_table "parties", :force => true do |t|
    t.integer  "game_id",    :limit => 11
    t.datetime "created_at"
    t.integer  "account_id", :limit => 11
  end

  create_table "players", :force => true do |t|
    t.integer  "party_id"
    t.integer  "member_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "smart_lists", :force => true do |t|
    t.text     "title"
    t.text     "query"
    t.integer  "account_id", :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "taggings", :force => true do |t|
    t.integer "tag_id",        :limit => 11
    t.integer "taggable_id",   :limit => 11
    t.string  "taggable_type"
  end

  add_index "taggings", ["tag_id", "taggable_id", "taggable_type"], :name => "index_taggings_on_tag_id_and_taggable_id_and_taggable_type"

  create_table "tags", :force => true do |t|
    t.string "name"
  end

  add_index "tags", ["name"], :name => "index_tags_on_name"

end
