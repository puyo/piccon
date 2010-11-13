class CreateAuthorizationIndexes < ActiveRecord::Migration
  def self.up
    add_index :authorizations, [:user_id], :unique => true
    add_index :authorizations, [:uid, :provider], :unique => true
  end

  def self.down
    remove_index :authorizations, [:user_id]
    remove_index :authorizations, [:uid, :provider]
  end
end
