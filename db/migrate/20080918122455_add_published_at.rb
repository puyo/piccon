class AddPublishedAt < ActiveRecord::Migration
  def self.up
    add_column "games", "published_at", :datetime, :null => true
  end

  def self.down
    remove_column "games", "published_at"
  end
end
