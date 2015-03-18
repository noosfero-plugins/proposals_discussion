require File.dirname(__FILE__) + '/../test_helper'

class TopicTest < ActiveSupport::TestCase

  def setup
    @discussion = fast_create(ProposalsDiscussionPlugin::Discussion)
    @profile = fast_create(Community)
    @topic = ProposalsDiscussionPlugin::Topic.new(:name => 'test', :profile => @profile, :parent => @discussion)
  end

  attr_reader :profile, :topic

  should 'return list of proposals' do
    topic.save!
    proposal1 = fast_create(ProposalsDiscussionPlugin::Proposal, :parent_id => topic.id)
    proposal2 = fast_create(ProposalsDiscussionPlugin::Proposal, :parent_id => topic.id)
    assert_equivalent [proposal1, proposal2], topic.proposals
  end

  should 'allow any user to create proposals in a topic' do
    assert topic.allow_create?(Person.new)
  end

  should 'return list of comments' do
    topic.save!
    proposal = fast_create(ProposalsDiscussionPlugin::Proposal, :parent_id => topic.id)
    comment1 = fast_create(Comment, :source_id => proposal.id)
    comment2 = fast_create(Comment, :source_id => proposal.id)
    assert_equivalent [comment1, comment2], topic.proposals_comments
  end

  should 'return list of authors' do
    topic.save!
    author1 = fast_create(Person)
    author2 = fast_create(Person)
    fast_create(ProposalsDiscussionPlugin::Proposal, :parent_id => topic.id, :created_by_id => author1)
    fast_create(ProposalsDiscussionPlugin::Proposal, :parent_id => topic.id, :created_by_id => author2)
    assert_equivalent [author1, author2], topic.proposals_authors
  end

  should 'return most active participants' do
    topic.save!
    author1 = fast_create(Person)
    author2 = fast_create(Person)
    fast_create(ProposalsDiscussionPlugin::Proposal, :parent_id => topic.id, :created_by_id => author1)
    fast_create(ProposalsDiscussionPlugin::Proposal, :parent_id => topic.id, :created_by_id => author2)
    fast_create(ProposalsDiscussionPlugin::Proposal, :parent_id => topic.id, :created_by_id => author2)
    assert_equal [author2, author1], topic.most_active_participants
  end

  should 'return max score' do
    person = fast_create(Person)
    proposal1 = ProposalsDiscussionPlugin::Proposal.create!(:parent => topic, :profile => profile, :name => "proposal1", :abstract => 'abstract')
    proposal2 = ProposalsDiscussionPlugin::Proposal.create!(:parent => topic, :profile => profile, :name => "proposal2", :abstract => 'abstract')
    10.times { Comment.create!(:source => proposal1, :body => "comment", :author => person) }
    5.times { Comment.create!(:source => proposal2, :body => "comment", :author => person) }
    assert_equal 10, topic.max_score
  end

end
