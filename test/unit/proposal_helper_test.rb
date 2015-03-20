require_relative '../test_helper'

class ProposalHelperTest < ActionView::TestCase

  def setup
    @proposal = ProposalsDiscussionPlugin::Proposal.new(:name => 'test', :abstract => 'abstract')
  end

  include ProposalsDiscussionPlugin::ProposalHelper

  attr_reader :proposal

  should 'display proposal score' do
    proposal.expects(:normalized_score).returns(1)
    assert proposal_score(proposal).present?
  end

  should 'not display score for unpublished proposals' do
    proposal.expects(:published?).returns(false)
    assert proposal_score(proposal).blank?
  end

  should 'display proposal locations' do
    proposal.expects(:locations).returns([Region.new])
    assert proposal_locations(proposal).present?
  end

  should 'return blank if a proposal has no locations' do
    proposal.expects(:locations).returns([])
    assert proposal_locations(proposal).blank?
  end

  should 'display proposal tags' do
    proposal.expects(:tags).returns([ActsAsTaggableOn::Tag.new])
    proposal.expects(:profile).returns(fast_create(Profile))
    assert proposal_tags(proposal).present?
  end

  should 'return blank if a proposal has no tags' do
    proposal.expects(:tags).returns([])
    assert proposal_tags(proposal).blank?
  end

end
