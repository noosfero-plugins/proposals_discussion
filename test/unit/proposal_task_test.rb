require_relative '../test_helper'

class ProposalTaskTest < ActiveSupport::TestCase

  attr_reader :profile, :person, :discussion

  def setup
    @person = fast_create(Person)
    @profile = fast_create(Community)
    @discussion = ProposalsDiscussionPlugin::Discussion.create!(:name => 'discussion', :profile => person, :allow_topics => false)
  end

  should 'check the source of a proposal in a task' do
    topic = fast_create(ProposalsDiscussionPlugin::Topic, :parent_id => discussion.id)
    task = ProposalsDiscussionPlugin::ProposalTask.new(:article_parent_id => topic.id)
    assert_equal topic.name, task.proposal_source
  end

  should 'assign proposal task to member with view_task permission' do
    role1 = Role.create!(:name => 'profile_role2', :permissions => ['perform_task'], :environment => Environment.default)
    role2 = Role.create!(:name => 'profile_role', :permissions => ['view_tasks'], :environment => Environment.default)

    person1 = fast_create(Person)
    person1.define_roles([role1], profile)
    person2 = fast_create(Person)
    person2.define_roles([role2], profile)

    task = ProposalsDiscussionPlugin::ProposalTask.create!(:requestor => person, :target => profile, :article => {:name => 'proposal 1', :abstract => 'proposal 1'})
    assert_equal person2, task.responsible
  end

end
