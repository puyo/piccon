class AddGalleries < ActiveRecord::Migration
  def self.up
    add_column "games", "name", :string, :null => true
    add_column "games", "thumbnail_post_id", :integer, :null => true

    add_index "games", "thumbnail_post_id" 

    create_table :lovers do |t|
      t.integer :user_id
      t.integer :game_id
    end

    add_index "lovers", "user_id" 
    add_index "lovers", "game_id" 
  end

  def self.down
    remove_column "games", "name"
    remove_column "games", "thumbnail_post_id"

    drop_table "lovers"
  end
end
