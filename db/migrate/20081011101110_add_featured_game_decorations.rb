class AddFeaturedGameDecorations < ActiveRecord::Migration
  def self.up
    add_column "games", "featured_thumbnail_post_id", :integer, :null => true
    add_index "games", "featured_thumbnail_post_id" 
  end

  def self.down
    remove_column "games", "featured_thumbnail_post_id"
  end
end
