class UpdateUsers < ActiveRecord::Migration
  class User < ActiveRecord::Base
    has_many :authorizations
  end

  def self.up
    old_users = Hash.new{|h,k| h[k] = {} }
    say_with_time "Fetching current users..." do
      execute('select * from users').each_hash{|x| old_users[x['facebook_id']] = x }
      # add users from posts table
      execute('select author_id as facebook_id from posts').each_hash do |x|
        old_users[x['facebook_id']].update(x)
      end
      execute('select user_id as facebook_id from players').each_hash do |x|
        old_users[x['facebook_id']].update(x)
      end
    end

    drop_table :users
    create_table :users do |t|
      t.string :name
      t.timestamps
    end
    create_table :authorizations do |t|
      t.string :provider, :null => false
      t.string :uid, :null => false
      t.integer :user_id, :null => false
      t.timestamps
    end
    ActiveRecord::Base.record_timestamps = false
    say_with_time "Recreating users..." do
      old_users.each do |facebook_id, user|
        new_user = UpdateUsers::User.create!(:updated_at => user['updated_at'], :created_at => user['created_at'])
        new_user.authorizations.new({
          :provider => 'facebook',
          :uid => facebook_id,
          :updated_at => user['updated_at'],
          :created_at => user['created_at'],
        }).save(false)
      end
    end
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration, '8)'
  end
end
