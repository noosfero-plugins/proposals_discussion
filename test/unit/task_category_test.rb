require_relative '../test_helper'

class TaskCategoryTest < ActiveSupport::TestCase

  def setup
    @person = fast_create(Person)
    @profile = fast_create(Community)
    @discussion = ProposalsDiscussionPlugin::Discussion.create!(:name => 'discussion', :profile => @person, :name => 'discussion')
    @proposal = ProposalsDiscussionPlugin::Proposal.create!(:name => 'test', :abstract => 'abstract', :profile => @profile, :parent => @discussion)
  end

  attr_reader :person, :profile, :discussion, :proposal

  should 'add a category to a task' do

    task_data = {
      article: {name: "test proposal", abstract: "teste adadd"},
      requestor: person,
      target:  profile,
      spam: false
    }

    task = ProposalsDiscussionPlugin::ProposalTask.new task_data

    category = ProposalsDiscussionPlugin::TaskCategory.create!(name: 'ProposalTest', environment: Environment.default)

    category.tasks << task;
    category.save!

    assert_equal task.id, category.tasks[0].id
  end

  should 'approve a proposal task without category' do

    task_data = {
      article: {name: "test proposal", abstract: "teste adadd"},
      requestor: person,
      target:  profile,
      spam: false
    }

    task = ProposalsDiscussionPlugin::ProposalTask.create! task_data
    evaluated_by = false

    assert_raise(ActiveRecord::RecordInvalid) { task.flag_accept_proposal evaluated_by }

  end

  should 'approve a proposal task with categories' do

    task_data = {
      article: {name: "test proposal", abstract: "teste adadd"},
      requestor: person,
      target:  profile,
      spam: false
    }
    task = ProposalsDiscussionPlugin::ProposalTask.create! task_data
    evaluated_by = false

    categories = [
      { name: 'ProposalTest', environment: Environment.default },
      { name: 'ProposalTestTwo', environment: Environment.default }
    ]
    categories.each do |category|
        task.categories << ProposalsDiscussionPlugin::TaskCategory.new(category)
    end

    assert_nothing_raised do
       task.flag_accept_proposal evaluated_by
    end

    assert_equal 2, task.categories.count

  end

end
