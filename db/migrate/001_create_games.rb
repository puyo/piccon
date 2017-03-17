class CreateGames < ActiveRecord::Migration
  def self.up
    create_table :games do |t|
      t.integer :owner_id
      t.integer :length, :default => 12
      t.integer :status, :default => 0
      t.timestamps
    end
  end

  def self.down
    drop_table :games
  end
end
