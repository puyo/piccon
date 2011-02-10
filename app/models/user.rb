class User < ActiveRecord::Base
  has_many :papers, :foreign_key => :owner_user_id

  def new?
    new_record?
  end
end
