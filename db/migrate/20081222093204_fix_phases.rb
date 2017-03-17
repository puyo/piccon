class FixPhases < ActiveRecord::Migration
  def self.old_is_draw_phase?(game)
    game.status == Game::STARTED and (game.posts.size % 2) == 0
  end

  def self.old_is_describe_phase?(game)
    game.status == Game::STARTED and (game.posts.size % 2) == 1
  end

  def self.up
    Game.all.each do |game|
      if old_is_draw_phase?(game)
        game.phase = Game::DRAW 
      elsif old_is_describe_phase?(game)
        game.phase = Game::DESCRIBE
      end
      game.save 
      $stderr.puts game.errors.full_messages if game.errors.any?
    end
  end

  def self.down
  end
end
