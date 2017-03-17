class CreateUsers < ActiveRecord::Migration
  class User < ActiveRecord::Base
  end

  class Player < ActiveRecord::Base
  end

  def self.up
    create_table :users, :id => false do |t|
      t.integer :facebook_id, :null => false, :unique => true
      t.timestamps
    end

    transaction do
      Player.all.each do |player|
        user = User.find_or_create_by_facebook_id(player.user_id)
        #user.save!
      end
    end
  end

  def self.down
    drop_table :users
  end
end
