class AddPhaseBoolean < ActiveRecord::Migration
  def self.up
    add_column "games", "phase", :boolean, :null => true
  end

  def self.down
    remove_column "games", "phase"
  end
end
