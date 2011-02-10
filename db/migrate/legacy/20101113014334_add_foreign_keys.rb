class AddForeignKeys < ActiveRecord::Migration

  def self.up
    remove_index 'lovers', :name => 'index_lovers_on_game_id'
    add_index :lovers, [:paper_id, :user_id], :unique => true
    add_index :players, [:paper_id, :user_id, :order_position], :unique => true
    add_index :sessions, [:session_id], :unique => true
    add_foreign_key :lovers, :users, :dependent => :delete
    add_foreign_key :lovers, :papers, :dependent => :delete
    add_foreign_key :players, :users, :dependent => :restrict
    add_foreign_key :players, :papers, :dependent => :delete
    add_foreign_key :posts, :users, :column => :author_user_id, :dependent => :restrict
    add_foreign_key :posts, :papers, :dependent => :delete

    add_foreign_key :papers, :users, :column => :owner_user_id, :dependent => :restrict
    add_foreign_key :papers, :users, :column => :current_player_id, :dependent => :restrict
    #add_foreign_key :papers, :players, :column => :last_player_id, :dependent => :restrict
    #add_foreign_key :papers, :players, :column => :second_last_player_id, :dependent => :restrict
    #add_foreign_key :papers, :posts, :column => :thumbnail_post_id, :dependent => :restrict
    #add_foreign_key :papers, :posts, :column => :featured_thumbnail_post_id, :dependent => :restrict
  end

  def self.down
    remove_foreign_key :papers, :name => :papers_owner_user_id_fk
    remove_foreign_key :posts, :name => :posts_paper_id_fk
    remove_foreign_key :posts, :name => :posts_author_user_id_fk
    remove_foreign_key :players, :name => :players_user_id_fk
    remove_foreign_key :players, :name => :players_paper_id_fk
    remove_foreign_key :lovers, :name => :lovers_paper_id_fk
    remove_foreign_key :lovers, :name => :lovers_user_id_fk
    remove_index :sessions, [:session_id]
    remove_index :players, [:paper_id, :user_id, :order_position]
    remove_index :lovers, [:paper_id, :user_id]
    add_index :lovers, [:paper_id], :name => 'index_lovers_on_game_id'
  end
end
