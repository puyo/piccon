class ChangeDefaultGameLength < ActiveRecord::Migration
  def self.up
      change_column "games", "length", :integer, :default => 12
  end

  def self.down
      change_column "games", "length", :integer, :default => 10
  end
end
