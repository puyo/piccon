class UpdateUsers < ActiveRecord::Migration
  class User < ActiveRecord::Base
  end

  def self.up
    old_users = Hash.new{|h,k| h[k] = {} }
    say_with_time "Fetching current users..." do
      [
        'SELECT author_id AS fb_id, false AS fb_auth FROM posts',
        'SELECT user_id AS fb_id, false AS fb_auth FROM players',
        'SELECT current_player_id AS fb_id, false AS fb_auth FROM games WHERE current_player_id IS NOT NULL',
        'SELECT last_player_id AS fb_id, false AS fb_auth FROM games WHERE last_player_id IS NOT NULL',
        'SELECT second_last_player_id AS fb_id, false AS fb_auth FROM games WHERE second_last_player_id IS NOT NULL',
        'SELECT facebook_id AS fb_id, true AS fb_auth FROM users',
      ].each do |sql|
        execute(sql).each_hash{|x| old_users[x['fb_id']].update(x) }
      end
    end

    drop_table :users
    create_table :users do |t|
      t.string :name
      t.string :fb_id
      t.boolean :fb_auth
      t.timestamps
    end
    add_index :users, [:fb_id], :unique => true
    add_index :users, [:fb_auth]

    ActiveRecord::Base.record_timestamps = false
    ActiveRecord::Base.transaction do
      say_with_time "Recreating users..." do
        old_users.each do |fb_id, user|
          UpdateUsers::User.create!(user)
        end
      end
    end
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration, '8)'
  end
end
