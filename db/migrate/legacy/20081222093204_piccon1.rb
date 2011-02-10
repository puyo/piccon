class Piccon1 < ActiveRecord::Migration
  def self.up
    create_table :games, :force => true do |t|
      t.integer  :owner_id
      t.integer  :length, :default => 12
      t.integer  :status, :default => 0 # and maturity rating
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :current_player_id
      t.datetime :finished_at
      t.string   :name
      t.integer  :thumbnail_post_id
      t.integer  :comment_count, :default => 0,  :null => false
      t.datetime :last_comment_at
      t.datetime :published_at
      t.integer  :featured_thumbnail_post_id
      t.integer  :last_player_id        # can't post if you were the last player
      t.integer  :second_last_player_id # can't post if you were the second last player
      t.datetime :assigned_at
      t.boolean  :phase
    end

    add_index :games, [:finished_at], :name => :index_games_on_finished_at
    add_index :games, [:updated_at], :name => :index_games_on_updated_at
    add_index :games, [:status], :name => :index_games_on_status
    add_index :games, [:thumbnail_post_id], :name => :index_games_on_thumbnail_post_id
    add_index :games, [:featured_thumbnail_post_id], :name => :index_games_on_featured_thumbnail_post_id

    create_table :lovers, :force => true do |t|
      t.integer :user_id
      t.integer :game_id
    end

    add_index :lovers, [:user_id], :name => :index_lovers_on_user_id
    add_index :lovers, [:game_id], :name => :index_lovers_on_game_id

    create_table :players, :force => true do |t|
      t.integer  :game_id
      t.integer  :user_id
      t.integer  :status
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :order_position, :null => false
    end

    add_index :players, [:game_id], :name => :index_players_on_game_id
    add_index :players, [:status], :name => :index_players_on_status
    add_index :players, [:user_id], :name => :index_players_on_user_id

    create_table :posts, :force => true do |t|
      t.integer  :game_id
      t.integer  :author_id
      t.string   :text
      t.string   :image_filename
      t.datetime :created_at
      t.datetime :updated_at
    end

    add_index :posts, [:game_id], :name => :index_posts_on_game_id

    create_table :sessions, :force => true do |t|
      t.string   :session_id, :null => false
      t.text     :data
      t.datetime :created_at
      t.datetime :updated_at
    end

    add_index :sessions, [:session_id], :name => :index_sessions_on_session_id
    add_index :sessions, [:updated_at], :name => :index_sessions_on_updated_at

    create_table :users, :id => false, :force => true do |t|
      t.integer  :facebook_id, :null => false
      t.datetime :created_at
      t.datetime :updated_at
    end
  end

  def self.down
    drop_table :users
    drop_table :sessions
    drop_table :posts
    drop_table :players
    drop_table :lovers
    drop_table :games
  end
end
