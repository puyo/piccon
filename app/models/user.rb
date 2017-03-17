class User < ActiveRecord::Base
  has_many :games, :through => :players
  has_many :players

  def self.primary_key
    'facebook_id'
  end
end
