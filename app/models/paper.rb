class Paper < ActiveRecord::Base
  has_many :posts
  has_many :invites
  belongs_to :owner, :class_name => 'User'

  scope :invited_or_rating_high_enough, lambda { |user|
    joins('LEFT JOIN invites ON (papers.id = invites.paper_id)').where('invites.user_id = ? OR papers.min_rating IS NULL OR papers.min_rating <= ?', user.id, user.rating)
  }

  scope :eligible, lambda { |user|
    invited_or_rating_high_enough(user).unclaimed.started.not_last_two(user)
  }

  scope :unclaimed, where(:claimant_id => nil)

  scope :started, where('papers.status >= ?', Status::STARTED)

  scope :not_last_two, lambda { |user|
    where('(papers.last_user_id IS NULL OR papers.last_user_id != :id) AND (papers.second_last_user_id IS NULL OR papers.second_last_user_id != :id)', :id => user.id)
  }

  attr_accessor :private

  def invite_only?
    invites.any?
  end
end
