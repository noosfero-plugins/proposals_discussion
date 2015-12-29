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

  should 'assign proposal task to member with perform_task permission after flag as accepted' do
    role1 = Role.create!(:name => 'profile_role2', :permissions => ['perform_task'], :environment => Environment.default)
    role2 = Role.create!(:name => 'profile_role', :permissions => ['view_tasks'], :environment => Environment.default)

    person1 = fast_create(Person)
    person1.define_roles([role1], profile)
    person2 = fast_create(Person)
    person2.define_roles([role2], profile)

    task = ProposalsDiscussionPlugin::ProposalTask.create!(:requestor => person, :target => profile, :article => {:name => 'proposal 1', :abstract => 'proposal 1'})
    task.categories = [fast_create(ProposalsDiscussionPlugin::TaskCategory)]
    task.flag_accept_proposal(person2)
    assert_equal person1, task.responsible
  end

  should 'assign proposal task to member with perform_task permission after flag as rejected' do
    role1 = Role.create!(:name => 'profile_role2', :permissions => ['perform_task'], :environment => Environment.default)
    role2 = Role.create!(:name => 'profile_role', :permissions => ['view_tasks'], :environment => Environment.default)

    person1 = fast_create(Person)
    person1.define_roles([role1], profile)
    person2 = fast_create(Person)
    person2.define_roles([role2], profile)

    task = ProposalsDiscussionPlugin::ProposalTask.create!(:requestor => person, :target => profile, :article => {:name => 'proposal 1', :abstract => 'proposal 1'})
    task.categories = [fast_create(ProposalsDiscussionPlugin::TaskCategory)]
    task.flag_reject_proposal(person2)
    assert_equal person1, task.responsible
  end

  should 'not change assignment when update the task responsible' do
    role1 = Role.create!(:name => 'profile_role2', :permissions => ['perform_task'], :environment => Environment.default)
    role2 = Role.create!(:name => 'profile_role', :permissions => ['view_tasks'], :environment => Environment.default)

    person1 = fast_create(Person)
    person1.define_roles([role1], profile)
    person2 = fast_create(Person)
    person2.define_roles([role2], profile)

    task = ProposalsDiscussionPlugin::ProposalTask.create!(:requestor => person, :target => profile, :article => {:name => 'proposal 1', :abstract => 'proposal 1'})
    task.categories = [fast_create(ProposalsDiscussionPlugin::TaskCategory)]
    task.flag_accept_proposal(person2)
    assert_equal person1, task.responsible
    task.responsible = person2
    task.save!
    assert_equal person2, task.responsible
  end

  should 'undo proposal task reject flag' do
    role1 = Role.create!(:name => 'profile_role2', :permissions => ['perform_task'], :environment => Environment.default)
    role2 = Role.create!(:name => 'profile_role', :permissions => ['view_tasks'], :environment => Environment.default)

    person1 = fast_create(Person)
    person1.define_roles([role1], profile)
    person2 = fast_create(Person)
    person2.define_roles([role2], profile)

    task = ProposalsDiscussionPlugin::ProposalTask.create!(:requestor => person, :target => profile, :article => {:name => 'proposal 1', :abstract => 'proposal 1'})
    task_two = ProposalsDiscussionPlugin::ProposalTask.create!(:requestor => person, :target => profile, :article => {:name => 'proposal 2', :abstract => 'proposal 2'})
    task.categories = task_two.categories = [fast_create(ProposalsDiscussionPlugin::TaskCategory)]
    task.flag_reject_proposal(person2)
    task_two.flag_reject_proposal(person2)
    assert task.flagged?
    assert task_two.flagged?

    ProposalsDiscussionPlugin::ProposalTask.undo_flags([task.id,task_two.id], person)
    task.reload
    task_two.reload

    assert_equal [false,false], [task.flagged?,task_two.flagged?]
    assert_equal [Task::Status::ACTIVE,Task::Status::ACTIVE], [task.status, task_two.status]
  end

  should 'do not fail on task information with integer as abstract' do
    task = ProposalsDiscussionPlugin::ProposalTask.new
    task.expects(:abstract).returns(49)
    assert task.information.present?
  end

  should 'create a proposal with category when accept a task' do
    c1 = fast_create(Category)
    discussion.categories << c1
    task = ProposalsDiscussionPlugin::ProposalTask.create!(:requestor => person, :target => profile, :article_parent_id => @discussion.id, :article => {:name => 'proposal 1', :abstract => 'proposal 1', :type => "ProposalsDiscussionPlugin::Proposal"})
    task.perform
    assert_equal [c1], ProposalsDiscussionPlugin::Proposal.last.categories
  end

end
