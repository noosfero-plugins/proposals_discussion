class ProposalsDiscussionPlugin::RankingItem < ActiveRecord::Base

  belongs_to :proposal

  attr_accessible :proposal, :abstract, :votes_for, :votes_against, :hits, :effective_support

  delegate :body, :to => :proposal

end
