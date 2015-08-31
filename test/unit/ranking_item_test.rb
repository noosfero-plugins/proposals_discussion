require_relative '../test_helper'

class RankingItemTest < ActiveSupport::TestCase

  def setup
    @profile = fast_create(Community)
    @person = fast_create(Person)
    @discussion = ProposalsDiscussionPlugin::Discussion.create!(:name => 'discussion', :profile => person, :allow_topics => false)
  end

  attr_reader :profile, :person, :discussion

  should 'return associated ranking item in proposal' do
    proposal = ProposalsDiscussionPlugin::Proposal.create!(:name => 'test', :abstract => 'abstract', :profile => profile, :parent => discussion)
    discussion.update_ranking
    assert proposal.ranking_item
  end

end
