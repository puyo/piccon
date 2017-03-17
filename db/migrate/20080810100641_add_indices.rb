class AddIndices < ActiveRecord::Migration
  def self.up
    add_index("games", "finished_at")
    add_index("games", "updated_at")
    add_index("games", "status")
    add_index("players", "game_id")
    add_index("players", "status")
    add_index("players", "user_id")
    add_index("posts", "game_id")
  end

  def self.down
    remove_index("games", "finished_at")
    remove_index("games", "updated_at")
    remove_index("games", "status")
    remove_index("players", "game_id")
    remove_index("players", "status")
    remove_index("players", "user_id")
    remove_index("posts", "game_id")
  end
end
