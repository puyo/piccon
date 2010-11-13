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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20101113010101) do

  create_table "authorizations", :force => true do |t|
    t.string   "provider",   :null => false
    t.string   "uid",        :null => false
    t.integer  "user_id",    :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "authorizations", ["provider"], :name => "index_authorizations_on_provider"
  add_index "authorizations", ["uid"], :name => "index_authorizations_on_uid"
  add_index "authorizations", ["user_id"], :name => "index_authorizations_on_user_id"

  create_table "games", :force => true do |t|
    t.integer  "owner_id"
    t.integer  "length",                     :default => 12
    t.integer  "status",                     :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "current_player_id"
    t.datetime "finished_at"
    t.integer  "comment_count",              :default => 0,  :null => false
    t.datetime "last_comment_at"
    t.string   "name"
    t.integer  "thumbnail_post_id"
    t.datetime "published_at"
    t.integer  "featured_thumbnail_post_id"
    t.integer  "last_player_id"
    t.integer  "second_last_player_id"
    t.datetime "assigned_at"
    t.boolean  "phase"
  end

  add_index "games", ["featured_thumbnail_post_id"], :name => "index_games_on_featured_thumbnail_post_id"
  add_index "games", ["finished_at"], :name => "index_games_on_finished_at"
  add_index "games", ["status"], :name => "index_games_on_status"
  add_index "games", ["thumbnail_post_id"], :name => "index_games_on_thumbnail_post_id"
  add_index "games", ["updated_at"], :name => "index_games_on_updated_at"

  create_table "lovers", :force => true do |t|
    t.integer "user_id"
    t.integer "game_id"
  end

  add_index "lovers", ["game_id"], :name => "index_lovers_on_game_id"
  add_index "lovers", ["user_id"], :name => "index_lovers_on_user_id"

  create_table "players", :force => true do |t|
    t.integer  "game_id"
    t.integer  "user_id"
    t.integer  "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "order_position", :null => false
  end

  add_index "players", ["game_id"], :name => "index_players_on_game_id"
  add_index "players", ["status"], :name => "index_players_on_status"
  add_index "players", ["user_id"], :name => "index_players_on_user_id"

  create_table "posts", :force => true do |t|
    t.integer  "game_id"
    t.integer  "author_id"
    t.string   "text"
    t.string   "image_filename"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "posts", ["game_id"], :name => "index_posts_on_game_id"

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "users", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
