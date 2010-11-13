class CreateAuthorizationIndexes < ActiveRecord::Migration
  def self.up
    add_index :authorizations, [:user_id], :name => :index_authorizations_on_user_id
    add_index :authorizations, [:uid], :name => :index_authorizations_on_uid
    add_index :authorizations, [:provider], :name => :index_authorizations_on_provider
  end

  def self.down
    remove_index :authorizations, :index_authorizations_on_user_id
    remove_index :authorizations, :index_authorizations_on_uid
    remove_index :authorizations, :index_authorizations_on_provider
  end
end
