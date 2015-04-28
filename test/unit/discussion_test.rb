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
    assert_equivalent [proposal1, proposal2], discussion.topics_proposals
  end

  should 'return max score' do
    person = fast_create(Person)
    discussion = ProposalsDiscussionPlugin::Discussion.create!(:profile => person, :name => 'discussion', :allow_topics => false)
    proposal1 = ProposalsDiscussionPlugin::Proposal.create!(:parent => discussion, :profile => profile, :name => "proposal1", :abstract => 'abstract')
    proposal2 = ProposalsDiscussionPlugin::Proposal.create!(:parent => discussion, :profile => profile, :name => "proposal2", :abstract => 'abstract')
    10.times { Comment.create!(:source => proposal1, :body => "comment", :author => person) }
    5.times { Comment.create!(:source => proposal2, :body => "comment", :author => person) }
    assert_equal 10, discussion.max_score
  end

  should 'allow new proposals if discussion phase is proposals' do
    discussion.phase = :proposals
    assert discussion.allow_new_proposals?
  end

  should 'not allow new proposals if discussion phase is vote' do
    discussion.phase = :vote
    assert !discussion.allow_new_proposals?
  end

  should 'not allow new proposals if discussion phase is finish' do
    discussion.phase = :finish
    assert !discussion.allow_new_proposals?
  end

  should 'not allow proposal creation by normal users if discussion is moderated' do
    discussion.moderate_proposals = true
    person = fast_create(Person)
    proposal = ProposalsDiscussionPlugin::Proposal.create!(:parent => discussion, :profile => profile, :name => "proposal1", :abstract => 'abstract')
    assert !discussion.allow_create?(person)
  end

  should 'allow proposal creation by admin users even when discussion is moderated' do
    discussion.moderate_proposals = true
    person = fast_create(Person)
    give_permission(person, 'post_content', profile)
    proposal = ProposalsDiscussionPlugin::Proposal.create!(:parent => discussion, :profile => profile, :name => "proposal1", :abstract => 'abstract')
    assert discussion.allow_create?(person)
  end

end
