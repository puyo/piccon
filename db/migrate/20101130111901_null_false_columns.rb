class NullFalseColumns < ActiveRecord::Migration
  def self.up
    change_column :lovers, :user_id, :integer, :null => false
    change_column :lovers, :paper_id, :integer, :null => false
    change_column :papers, :owner_user_id, :integer, :null => false
    change_column :players, :paper_id, :integer, :null => false
    change_column :players, :user_id, :integer, :null => false
    change_column :posts, :paper_id, :integer, :null => false
    change_column :posts, :author_user_id, :integer, :null => false
  end

  def self.down
    change_column :posts, :author_user_id, :integer
    change_column :posts, :paper_id, :integer
    change_column :players, :user_id, :integer
    change_column :players, :paper_id, :integer
    change_column :papers, :owner_user_id, :integer
    change_column :lovers, :paper_id, :integer
    change_column :lovers, :user_id, :integer
  end
end
