# Models:
#
# Game (id, owner_id, status, timestamps)
#
# Player (id, game_id, user_id)
#
# Paper (id, game_id, length, current_player_id,
# gallery_id, flagged_inappropriate, created_at, updated_at, finished_at,
# thumbnail_post_id, comments_id)
#
# Comments (id, comment_count, last_comment_at)
# Lovers (id, user_id, paper_id)
# Post (id, paper_id, type)
# Description < Post (text)
# Drawing < Post (paperclip image)
# Gallery (id, name, maturity_rating)
# Like (id, user_id, paper_id)

class CreateSchema < ActiveRecord::Migration
  def self.up
    create_table :sessions, :force => true do |t|
      t.string   :session_id, :null => false
      t.text     :data
      t.timestamps
    end

    add_index :sessions, [:session_id], :name => :index_sessions_on_session_id
    add_index :sessions, [:updated_at], :name => :index_sessions_on_updated_at

    create_table :users do |t|
      t.string :name, :null => false
      t.integer :rating, :null => false # cache of the number of games that have been loved
      t.timestamps
    end

    create_table :authorizations do |t|
      t.string :provider, :null => false
      t.string :uid, :null => false
      t.integer :user_id, :null => false
      t.timestamps
    end

    add_index :authorizations, [:user_id], :name => :index_authorizations_on_user_id

    create_table :players do |t|
      t.integer  :paper_id, :null => false
      t.integer  :user_id, :null => false
      t.integer  :status, :null => false, :default => 0
      t.integer  :order, :null => false, :default => 0
      t.timestamps
    end

    add_index :players, [:paper_id], :name => :index_players_on_paper_id
    add_index :players, [:user_id], :name => :index_players_on_user_id
    add_index :players, [:status], :name => :index_players_on_status
    add_index :players, [:order], :name => :index_players_on_order

    create_table :papers do |t|
      t.integer  :owner_user_id, :null => false
      t.integer  :length, :null => false, :default => 12
      t.integer  :status, :null => false, :default => 0 # and maturity rating
      t.integer  :start_with_description, :null => false, :default => false
      t.integer  :current_player_id
      t.integer  :last_player_id        # can't post if you were the last player
      t.integer  :second_last_player_id # can't post if you were the second last player
      t.timestamps
      t.datetime :assigned_to_current_player_at
      t.datetime :finished_at
    end

    add_index :papers, [:finished_at], :name => :index_papers_on_finished_at
    add_index :papers, [:updated_at], :name => :index_papers_on_updated_at
    add_index :papers, [:status], :name => :index_papers_on_status
    add_index :papers, [:thumbnail_post_id], :name => :index_papers_on_thumbnail_post_id

    create_table :gallery do |t|
      t.integer :rating, :null => false
    end

    create_table :gallery_papers do |t|
      t.integer  :paper_id, :null => false
      t.integer  :gallery_id, :null => false
      t.string   :paper_name, :null => false
      t.integer  :drawing_post_id, :null => false
      t.integer  :comment_count, :null => false, :default => 0
      t.datetime :commented_at
      t.timestamps
    end

    create_table :paper_lovers do |t|
      t.integer :user_id, :null => false
      t.integer :paper_id, :null => false
    end

    add_index :paper_lovers, [:user_id], :name => :index_paper_lovers_on_user_id
    add_index :paper_lovers, [:paper_id], :name => :index_paper_lovers_on_paper_id

    create_table :posts, :force => true do |t|
      t.string   :type
      t.integer  :paper_id, :null => false
      t.integer  :author_id, :null => false
      t.string   :text
      #t.string   :image_filename # TODO: paperclip
      t.timestamps
    end

    add_index :posts, [:paper_id], :name => :index_posts_on_paper_id

    # foreign keys
    change_table :authorizations do |t|
      t.foreign_key :users, :dependent => :delete
    end
  end
end
