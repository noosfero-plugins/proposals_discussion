require_relative '../test_helper'

class TaskCategory < ActiveSupport::TestCase

  def setup
    @person = fast_create(Person)
    @profile = fast_create(Community)
    @discussion = ProposalsDiscussionPlugin::Discussion.create!(:name => 'discussion', :profile => @person, :name => 'discussion')
    @proposal = ProposalsDiscussionPlugin::Proposal.create!(:name => 'test', :abstract => 'abstract', :profile => @profile, :parent => @discussion)
  end

  attr_reader :person, :profile, :discussion, :proposal

  should 'add a category to a task' do
    requestor = fast_create(Person)
    task_data = {
      :requestor => requestor,
      :target => person,
      :spam => false
    }

    task = Task.create!(task_data)

    category = ProposalsDiscussionPlugin::TaskCategory.create!(name: 'ProposalTest', tasks: [task])

    assert_equal task.id, category.tasks[0].id
  end

end
