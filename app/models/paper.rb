class Paper < ActiveRecord::Base
  has_many :posts

  named_scope :is_an_assigned_player, lambda { |user|
    {
      :conditions => ['(paper.has_players AND players.user_id = ?)', user.id],
      :joins => 'LEFT JOIN players ON (players.paper_id = paper.id)',
    }
  }

  named_scope :satisfies_rating, lambda { |user|
    {
      :conditions => ['(paper.min_rating IS NULL OR paper.min_rating <= ?', user.rating],
    }
  }

  attr_accessor :private
end
