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

ActiveRecord::Schema.define(:version => 20101028113724) do

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
    t.date     "last_play"
  end

  add_index "account_games", ["account_id"], :name => "index_account_games_on_account_id"
  add_index "account_games", ["game_id"], :name => "index_account_games_on_game_id"

  create_table "accounts", :force => true do |t|
    t.string   "login"
    t.string   "email"
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.string   "api_key",                   :limit => 40, :default => ""
    t.boolean  "game",                                    :default => true
    t.boolean  "party",                                   :default => true
    t.boolean  "member",                                  :default => true
  end

  create_table "assets", :force => true do |t|
    t.string   "content_type"
    t.string   "filename"
    t.integer  "size",            :limit => 11
    t.integer  "width",           :limit => 11
    t.integer  "height",          :limit => 11
    t.integer  "attachable_id",   :limit => 11
    t.string   "attachable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "authors", :force => true do |t|
    t.string "name"
    t.string "surname"
    t.string "homepage"
    t.string "lang",     :default => ""
  end

  create_table "authorships", :force => true do |t|
    t.integer "author_id", :limit => 11
    t.integer "game_id",   :limit => 11
  end

  add_index "authorships", ["author_id"], :name => "index_authorships_on_author_id"
  add_index "authorships", ["game_id"], :name => "index_authorships_on_game_id"

  create_table "collections", :force => true do |t|
    t.text     "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "editions", :force => true do |t|
    t.integer  "game_id",          :limit => 11
    t.integer  "editor_id",        :limit => 11
    t.text     "lang"
    t.text     "name"
    t.date     "published_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "box_file_name"
    t.string   "box_content_type"
    t.integer  "box_file_size"
    t.datetime "box_updated_at"
  end

  add_index "editions", ["editor_id"], :name => "index_editions_on_editor_id"
  add_index "editions", ["game_id"], :name => "index_editions_on_game_id"

  create_table "editors", :force => true do |t|
    t.text     "name"
    t.text     "homepage"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "lang"
    t.string   "logo_file_name"
    t.string   "logo_content_type"
    t.integer  "logo_file_size"
    t.datetime "logo_updated_at"
    t.integer  "editions_count",    :default => 0
  end

  create_table "extensions", :force => true do |t|
    t.integer  "base_game_id"
    t.integer  "extension_id"
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
    t.integer  "difficulty",       :limit => 11, :default => 2
    t.integer  "min_player",       :limit => 11, :default => 1
    t.integer  "max_player",       :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "url"
    t.float    "average",                        :default => 0.0
    t.integer  "target",           :limit => 11, :default => 0
    t.integer  "time_category",    :limit => 11, :default => 0
    t.string   "box_file_name"
    t.string   "box_content_type"
    t.integer  "box_file_size"
    t.datetime "box_updated_at"
    t.integer  "collection_id"
    t.integer  "base_game_id"
    t.boolean  "standalone"
  end

  create_table "homepages", :force => true do |t|
    t.integer  "account_id"
    t.boolean  "public"
    t.text     "title"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "members", :force => true do |t|
    t.text     "name"
    t.text     "nickname"
    t.integer  "account_id", :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "email"
  end

  add_index "members", ["account_id"], :name => "index_members_on_account_id"

  create_table "parties", :force => true do |t|
    t.integer  "game_id",       :limit => 11
    t.datetime "created_at"
    t.integer  "account_id",    :limit => 11
    t.integer  "players_count"
  end

  add_index "parties", ["account_id"], :name => "index_parties_on_account_id"
  add_index "parties", ["game_id"], :name => "index_parties_on_game_id"

  create_table "players", :force => true do |t|
    t.integer  "party_id",   :limit => 11
    t.integer  "member_id",  :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "players", ["member_id"], :name => "index_players_on_member_id"
  add_index "players", ["party_id"], :name => "index_players_on_party_id"

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

  create_table "user_pages", :force => true do |t|
    t.integer  "account_id"
    t.string   "name"
    t.text     "template"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title"
    t.boolean  "partial"
    t.string   "extension"
  end

end
