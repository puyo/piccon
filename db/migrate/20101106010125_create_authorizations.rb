class CreateAuthorizations < ActiveRecord::Migration
  def self.up
    create_table :authorizations do |t|
      t.string :provider
      t.string :uid
      t.references :user
      t.timestamps
    end

    change_table :authorizations do |t|
      t.foreign_key :users, :dependent => :delete
    end
  end

  def self.down
    drop_table :authorizations
  end
end
