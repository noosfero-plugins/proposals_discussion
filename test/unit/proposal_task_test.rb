require_relative '../test_helper'

class ProposalTaskTest < ActiveSupport::TestCase

  attr_reader :profile, :proposal, :person, :discussion

  def setup
    @person = fast_create(Person)
    @discussion = ProposalsDiscussionPlugin::Discussion.create!(:name => 'discussion', :profile => person, :allow_topics => false)
  end

  should 'check the source of a proposal in a task' do
    topic = fast_create(ProposalsDiscussionPlugin::Topic, :parent_id => discussion.id)
    task = ProposalsDiscussionPlugin::ProposalTask.new(:article_parent_id => topic.id)
    assert_equal topic.name, task.proposal_source
  end

end
