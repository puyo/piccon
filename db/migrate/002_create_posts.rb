class CreatePosts < ActiveRecord::Migration
  def self.up
    create_table :posts do |t|
      t.belongs_to :game
      t.integer :author_id # facebook user id
      t.string :text
      t.string :image_filename # replace with image plugin
      t.timestamps
    end
  end

  def self.down
    drop_table :posts
  end
end
