class DefaultCommentCount < ActiveRecord::Migration
  def self.up
     change_column "games", "comment_count", :integer, :null => false, :default => 0
  end

  def self.down
     change_column "games", "comment_count", :integer, :null => false
  end
end
