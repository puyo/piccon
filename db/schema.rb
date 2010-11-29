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

ActiveRecord::Schema.define(:version => 20101113014334) do

  create_table "lovers", :force => true do |t|
    t.integer "user_id"
    t.integer "paper_id"
  end

  add_index "lovers", ["paper_id", "user_id"], :name => "index_lovers_on_paper_id_and_user_id", :unique => true
  add_index "lovers", ["user_id"], :name => "index_lovers_on_user_id"

  create_table "papers", :force => true do |t|
    t.integer  "owner_user_id"
    t.integer  "length",                     :default => 12, :null => false
    t.integer  "status",                     :default => 0,  :null => false
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

  add_index "papers", ["current_player_id"], :name => "papers_current_player_id_fk"
  add_index "papers", ["featured_thumbnail_post_id"], :name => "index_games_on_featured_thumbnail_post_id"
  add_index "papers", ["finished_at"], :name => "index_games_on_finished_at"
  add_index "papers", ["owner_user_id"], :name => "papers_owner_user_id_fk"
  add_index "papers", ["status"], :name => "index_games_on_status"
  add_index "papers", ["thumbnail_post_id"], :name => "index_games_on_thumbnail_post_id"
  add_index "papers", ["updated_at"], :name => "index_games_on_updated_at"

  create_table "players", :force => true do |t|
    t.integer  "paper_id"
    t.integer  "user_id"
    t.integer  "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "order_position", :null => false
  end

  add_index "players", ["paper_id", "user_id", "order_position"], :name => "index_players_on_paper_id_and_user_id_and_order_position", :unique => true
  add_index "players", ["paper_id"], :name => "index_players_on_game_id"
  add_index "players", ["status"], :name => "index_players_on_status"
  add_index "players", ["user_id"], :name => "index_players_on_user_id"

  create_table "posts", :force => true do |t|
    t.integer  "paper_id"
    t.integer  "author_user_id"
    t.string   "text"
    t.string   "image_filename"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "posts", ["author_user_id"], :name => "index_posts_on_author_user_id"
  add_index "posts", ["paper_id"], :name => "index_posts_on_game_id"

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
    t.string   "fb_id"
    t.boolean  "fb_auth"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["fb_auth"], :name => "index_users_on_fb_auth"
  add_index "users", ["fb_id"], :name => "index_users_on_fb_id", :unique => true

  add_foreign_key "lovers", "papers", :name => "lovers_paper_id_fk", :dependent => :delete
  add_foreign_key "lovers", "users", :name => "lovers_user_id_fk", :dependent => :delete

  add_foreign_key "papers", "users", :name => "papers_current_player_id_fk", :column => "current_player_id"
  add_foreign_key "papers", "users", :name => "papers_owner_user_id_fk", :column => "owner_user_id"

  add_foreign_key "players", "papers", :name => "players_paper_id_fk", :dependent => :delete
  add_foreign_key "players", "users", :name => "players_user_id_fk"

  add_foreign_key "posts", "papers", :name => "posts_paper_id_fk", :dependent => :delete
  add_foreign_key "posts", "users", :name => "posts_author_user_id_fk", :column => "author_user_id"

end
