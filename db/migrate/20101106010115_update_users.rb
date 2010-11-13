class UpdateUsers < ActiveRecord::Migration
  class Authorizations < ActiveRecord::Base
  end
  class User < ActiveRecord::Base
    has_many :authorizations
  end

  def self.up
    old_users = []
    say_with_time "Fetching current users..." do
      ActiveRecord::Base.connection.execute('select * from users').each_hash{|x| old_users << x }
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
      old_users.each do |user|
        new_user = User.create!(:updated_at => user['updated_at'], :created_at => user['created_at'])
        authorization = new_user.authorizations.create!({
          :provider => 'facebook',
          :uid => user['facebook_id'],
          :updated_at => user['updated_at'],
          :created_at => user['created_at'],
        })
      end
    end
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration, '8)'
  end
end
