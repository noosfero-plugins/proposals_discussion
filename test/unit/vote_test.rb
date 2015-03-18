require_relative '../test_helper'

class VoteTest < ActiveSupport::TestCase

  def setup
    @person = fast_create(Person)
    @profile = fast_create(Community)
    @discussion = ProposalsDiscussionPlugin::Discussion.create!(:name => 'discussion', :profile => @person, :name => 'discussion')
    @proposal = ProposalsDiscussionPlugin::Proposal.create!(:name => 'test', :abstract => 'abstract', :profile => @profile, :parent => @discussion)
  end

  attr_reader :profile, :proposal, :person, :discussion

  should 'vote for articles that are not proposals' do
    article = fast_create(Article)
    vote = Vote.new(:voteable => article, :voter => person, :vote => 1)
    assert vote.save
  end

  should 'vote for a proposal of a discussion in proposals phase' do
    proposal.discussion.phase = :proposals
    vote = Vote.new(:voteable => proposal, :voter => person, :vote => 1)
    assert vote.save
  end

  should 'vote for a proposal of a discussion in vote phase' do
    proposal.discussion.phase = :vote
    vote = Vote.new(:voteable => proposal, :voter => person, :vote => 1)
    assert vote.save
  end

  should 'not vote for a proposal of a finished discussion' do
    proposal.discussion.phase = :finish
    vote = Vote.new(:voteable => proposal, :voter => person, :vote => 1)
    assert !vote.save
  end

  should 'not destroy a proposal vote of a finished discussion' do
    proposal.discussion.phase = :vote
    vote = Vote.new(:voteable => proposal, :voter => person, :vote => 1)
    assert vote.save
    proposal.discussion.phase = :finish
    assert !vote.destroy
  end

  should 'destroy a proposal vote of a discussion in vote phase' do
    proposal.discussion.phase = :vote
    vote = Vote.new(:voteable => proposal, :voter => person, :vote => 1)
    assert vote.save
    assert vote.destroy
  end

end
