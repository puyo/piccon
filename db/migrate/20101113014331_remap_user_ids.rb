class RemapUserIds < ActiveRecord::Migration
  def self.up
    add_index :posts, :author_user_id

    ActiveRecord::Base.transaction do
      cols = [
        [:players, :user_id],
        [:posts, :author_user_id],
        [:papers, :owner_user_id],
      ].each do |table, col|
        execute("UPDATE #{table}, authorizations SET #{table}.#{col} = authorizations.user_id WHERE #{table}.#{col} = authorizations.uid AND authorizations.provider = 'facebook'")
      end
    end
  end

  def self.down
    remove_index :posts, [:author_user_id]
  end
end
