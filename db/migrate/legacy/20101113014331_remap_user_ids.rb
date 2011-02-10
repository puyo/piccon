class RemapUserIds < ActiveRecord::Migration
  def self.up
    add_index :posts, :author_user_id

    ActiveRecord::Base.transaction do
      cols = [
        [:players, :user_id],
        [:posts, :author_user_id],
        [:papers, :owner_user_id],
        [:papers, :current_player_id],
        [:papers, :last_player_id],
        [:papers, :second_last_player_id],
      ].each do |table, col|
        execute(<<-SQL)
          UPDATE #{table}, users
          SET #{table}.#{col} = users.id
          WHERE #{table}.#{col} = users.fb_id
        SQL
      end
    end
  end

  def self.down
    remove_index :posts, [:author_user_id]
  end
end
