class AddPlayerOrder < ActiveRecord::Migration
  def self.up
    
    add_column "players", "order_position", :integer, :null => false

    Game.find(:all).each do |game|
      Player.record_timestamps = false
      begin
        game.players.each_with_index do |player, i|
          player.order_position = i
          player.save
          $stderr.puts player.errors.full_messages if player.errors.any?
        end
      ensure
        Player.record_timestamps = true
      end
      $stderr.puts game.errors.full_messages if game.errors.any?
    end
  end

  def self.down
    remove_column "players", "order_position"
  end
end
