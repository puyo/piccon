class AddFinishedAtColumn < ActiveRecord::Migration
  def self.up
    add_column "games", "finished_at", :datetime, :null => true

    Game.find(:all).each do |game|
      if game.is_finished?
        game.finished_at = game.updated_at
        game.save
        $stderr.puts game.errors.full_messages if game.errors.any?
      end
    end
  end

  def self.down
    remove_column "games", "finished_at"
  end
end
