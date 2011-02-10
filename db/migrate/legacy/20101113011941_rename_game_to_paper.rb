class RenameGameToPaper < ActiveRecord::Migration
  def self.up
    rename_table :games, :papers
    rename_column :posts, :game_id, :paper_id
    rename_column :players, :game_id, :paper_id
    rename_column :posts, :author_id, :author_user_id
    rename_column :papers, :owner_id, :owner_user_id
    change_column :papers, :length, :integer, :null => false, :default => 12
    change_column :papers, :status, :integer, :null => false, :default => 0
    rename_column :lovers, :game_id, :paper_id
  end

  def self.down
    rename_column :lovers, :paper_id, :game_id
    change_column :papers, :status, :integer, :default => 0
    change_column :papers, :length, :integer, :default => 12
    rename_column :papers, :owner_user_id, :owner_id
    rename_column :posts, :author_user_id, :author_id
    rename_column :players, :paper_id, :game_id
    rename_column :posts, :paper_id, :game_id
    rename_table :papers, :games
  end
end
