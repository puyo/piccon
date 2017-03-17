class PublicGames < ActiveRecord::Migration
  def self.up
    change_column "games", "current_player_id", :integer, :null => true
    add_column "games", "last_player_id", :integer, :null => true
    add_column "games", "second_last_player_id", :integer, :null => true
    add_column "games", "assigned_at", :timestamp, :null => true
  end

  def self.down
    remove_column "games", "assigned_at"
    remove_column "games", "second_last_player_id"
    remove_column "games", "last_player_id"
    change_column "games", "current_player_id", :integer, :null => false
  end
end
