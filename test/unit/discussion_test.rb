require File.dirname(__FILE__) + '/../test_helper'

class DiscussionTest < ActiveSupport::TestCase

  def setup
    @profile = fast_create(Community)
    @discussion = ProposalsDiscussionPlugin::Discussion.new(:name => 'test', :profile => @profile)
  end

  attr_reader :profile, :discussion

  should 'return list of topics' do
    discussion.save!
    topic1 = fast_create(ProposalsDiscussionPlugin::Topic, :parent_id => discussion.id)
    topic2 = fast_create(ProposalsDiscussionPlugin::Topic, :parent_id => discussion.id)
    assert_equivalent [topic1, topic2], discussion.topics
  end

  should 'return list of proposals' do
    discussion.save!
    topic = fast_create(ProposalsDiscussionPlugin::Topic, :parent_id => discussion.id)
    proposal1 = fast_create(ProposalsDiscussionPlugin::Proposal, :parent_id => topic.id)
    proposal2 = fast_create(ProposalsDiscussionPlugin::Proposal, :parent_id => topic.id)
    assert_equivalent [proposal1, proposal2], discussion.proposals
  end

end
