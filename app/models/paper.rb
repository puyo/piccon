class Paper < ActiveRecord::Base
  has_many :posts
  has_many :invites

  scope :is_invited, lambda { |user|
    joins(:invites).where('invites.user_id' => user.id)
  }

  scope :satisfies_rating, lambda { |user|
    where('min_rating IS NULL OR min_rating <= ?', user.rating)
  }

  scope :is_eligible, lambda { |user|
    {
      :conditions => ['(invites.user_id = ?) OR (papers.min_rating IS NULL OR papers.min_rating <= ?)', user.id, user.rating],
    }
  }

  attr_accessor :private
end
