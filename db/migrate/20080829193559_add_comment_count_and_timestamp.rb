class AddCommentCountAndTimestamp < ActiveRecord::Migration
  def self.up
     add_column "games", "comment_count", :integer, :null => false
     add_column "games", "last_comment_at", :timestamp, :null => true

    Game.find(:all).each do |game|
      Game.record_timestamps = false
      begin
          game.comment_count = 0
          game.save
          $stderr.puts game.errors.full_messages if game.errors.any?
      ensure
        Game.record_timestamps = true
      end
      $stderr.puts game.errors.full_messages if game.errors.any?
    end
  end

  def self.down
    remove_column "games", "comment_count"
    remove_column "games", "last_comment_at"
 end
end
