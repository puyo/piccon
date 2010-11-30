class Player < ActiveRecord::Base
  STATUSES = [
    STATUS_ACTIVE = 0,
    STATUS_DROPPED = 1,
  ]

  belongs_to :paper
  belongs_to :user
  validates :status, :inclusion => STATUSES

  named_scope :active, :conditions => ['status = ?', Player::STATUS_ACTIVE]
  named_scope :ordered, :order => :order_position

  def is_active?
    status == ACTIVE
  end
end
