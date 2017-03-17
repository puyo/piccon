class GameCurrentPlayer < ActiveRecord::Migration
  def self.up
    add_column "games", "current_player_id", :integer

    Game.find(:all).each do |game|
      game.current_player_id = game.current_turn_player.user_id
      game.save
      $stderr.puts game.errors.full_messages if game.errors.any?
    end

    change_column "games", "current_player_id", :integer, :null => false
  end

  def self.down
    remove_column "games", "current_player_id"
  end
end
