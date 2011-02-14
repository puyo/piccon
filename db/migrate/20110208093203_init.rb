class Init < ActiveRecord::Migration
  def self.up
    create_table 'lovers', :force => true do |t|
      t.integer 'user_id',  :null => false
      t.integer 'paper_id', :null => false
    end

    add_index 'lovers', ['paper_id', 'user_id'], :name => 'index_lovers_on_paper_id_and_user_id', :unique => true
    add_index 'lovers', ['user_id'], :name => 'index_lovers_on_user_id'

    create_table 'papers', :force => true do |t|
      t.integer  'owner_id', :null => false
      t.integer  'length',   :default => 12, :null => false
      t.integer  'status',   :default => 0,  :null => false

      t.integer  'second_last_user_id'
      t.integer  'last_user_id'
      t.integer  'claimant_id'
      t.datetime 'claimed_at'

      t.integer  'min_rating'

      t.datetime 'finished_at'

      t.datetime 'created_at'
      t.datetime 'updated_at'
    end

    add_index 'papers', ['claimant_id'], :name => 'papers_claimant_id_fk'
    add_index 'papers', ['finished_at'], :name => 'index_papers_on_finished_at'
    add_index 'papers', ['owner_id'], :name => 'papers_owner_id_fk'
    add_index 'papers', ['last_user_id'], :name => 'papers_last_user_id'
    add_index 'papers', ['second_last_user_id'], :name => 'papers_second_last_user_id'
    add_index 'papers', ['status'], :name => 'index_papers_on_status'
    add_index 'papers', ['updated_at'], :name => 'index_papers_on_updated_at'

    create_table 'gallery_papers', :force => true do |t|
      t.string   'title'
      t.integer  'paper_id',      :null => false
      t.integer  'gallery_id',    :null => false
      t.integer  'thumbnail_id',  :null => false
      t.integer  'comment_count', :default => 0, :null => false
      t.datetime 'commented_at'
      t.datetime 'created_at'
      t.datetime 'updated_at'
    end

    add_index 'gallery_papers', ['paper_id'], :name => 'index_papers_on_paper_id'
    add_index 'gallery_papers', ['gallery_id'], :name => 'index_papers_on_gallery_id'
    add_index 'gallery_papers', ['thumbnail_id'], :name => 'index_papers_on_thumbnail_id'

    create_table 'invites', :force => true do |t|
      t.integer  'paper_id', :null => false
      t.integer  'user_id',  :null => false
      t.integer  'position', :null => false, :default => 0
      t.integer  'status'
      t.datetime 'created_at'
      t.datetime 'updated_at'
    end

    add_index 'invites', ['paper_id', 'user_id', 'position'], :name => 'index_invites_on_paper_id_and_user_id_and_position', :unique => true
    add_index 'invites', ['paper_id'], :name => 'index_invites_on_game_id'
    add_index 'invites', ['status'], :name => 'index_invites_on_status'
    add_index 'invites', ['user_id'], :name => 'index_invites_on_user_id'

    create_table 'posts', :force => true do |t|
      t.integer  'paper_id',  :null => false
      t.integer  'author_id', :null => false
      t.string   'text'
      t.datetime 'created_at'
      t.datetime 'updated_at'
    end

    add_index 'posts', ['author_id'], :name => 'index_posts_on_author_id'
    add_index 'posts', ['paper_id'], :name => 'index_posts_on_game_id'

    create_table 'sessions', :force => true do |t|
      t.string   'session_id', :null => false
      t.text     'data'
      t.datetime 'created_at'
      t.datetime 'updated_at'
    end

    add_index 'sessions', ['session_id'], :name => 'index_sessions_on_session_id'
    add_index 'sessions', ['updated_at'], :name => 'index_sessions_on_updated_at'

    create_table 'users', :force => true do |t|
      t.string   'nickname', :null => false
      t.integer  'rating',   :null => false, :default => 0
      t.string   'fb_id'
      t.boolean  'fb_auth'
      t.datetime 'created_at'
      t.datetime 'updated_at'
    end

    add_index 'users', ['fb_auth'], :name => 'index_users_on_fb_auth'
    add_index 'users', ['fb_id'], :name => 'index_users_on_fb_id', :unique => true

    create_table 'galleries', :force => true do |t|
      t.string   'title',  :null => false
      t.integer  'rating', :null => false, :default => 0
      t.datetime 'created_at'
      t.datetime 'updated_at'
    end

    add_foreign_key 'lovers', 'papers', :name => 'lovers_paper_id_fk', :dependent => :delete
    add_foreign_key 'lovers', 'users', :name => 'lovers_user_id_fk', :dependent => :delete

    add_foreign_key 'papers', 'users', :name => 'papers_claimant_id_fk', :column => 'claimant_id'
    add_foreign_key 'papers', 'users', :name => 'papers_owner_id_fk', :column => 'owner_id'
    add_foreign_key 'papers', 'users', :name => 'papers_last_user_id_fk', :column => 'last_user_id'
    add_foreign_key 'papers', 'users', :name => 'papers_second_last_user_id_fk', :column => 'second_last_user_id'

    add_foreign_key 'invites', 'papers', :name => 'invites_paper_id_fk', :dependent => :delete
    add_foreign_key 'invites', 'users', :name => 'invites_user_id_fk'

    add_foreign_key 'posts', 'papers', :name => 'posts_paper_id_fk', :dependent => :delete
    add_foreign_key 'posts', 'users', :name => 'posts_author_id_fk', :column => 'author_id'

    add_foreign_key 'gallery_papers', 'papers', :name => 'gallery_papers_paper_id_fk', :column => 'paper_id'
    add_foreign_key 'gallery_papers', 'galleries', :name => 'gallery_papers_gallery_id_fk', :column => 'gallery_id'
    add_foreign_key 'gallery_papers', 'posts', :name => 'gallery_papers_thumbnail_id_fk', :column => 'thumbnail_id'
  end

  def self.down
  end
end
