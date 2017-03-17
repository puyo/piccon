class Player < ActiveRecord::Base
  belongs_to :game
  validates_numericality_of :user_id
  validates_numericality_of :status, :message => "is not a valid status"

  # Status
  ACTIVE = 0
  DROPPED = 1

  named_scope :active, :conditions => ['status = ?', Player::ACTIVE]
  named_scope :except, lambda{|user_id| 
    { :conditions => ['user_id != ?', user_id] }
  }
  named_scope :in_order, :order => :order_position

  def is_active?
    status == ACTIVE
  end
end
