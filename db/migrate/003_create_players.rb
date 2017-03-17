class CreatePlayers < ActiveRecord::Migration
  def self.up
    create_table :players do |t|
      t.belongs_to :game
      t.integer :user_id
      t.integer :status
      t.timestamps
    end
  end

  def self.down
    drop_table :players
  end
end
