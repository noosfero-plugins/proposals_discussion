class ProposalsDiscussionPlugin::RankingItem < Noosfero::Plugin::ActiveRecord

  belongs_to :proposal

  attr_accessible :proposal, :abstract, :votes_for, :votes_against, :hits, :effective_support

end
