class Paper < ActiveRecord::Base
  has_many :posts

  attr_accessor :private
end
