require File.dirname(__FILE__) + '/../test_helper'

class ProposalTest < ActiveSupport::TestCase

  def setup
    @profile = fast_create(Community)
    @person = fast_create(Person)
    @proposal = ProposalsDiscussionPlugin::Proposal.new(:name => 'test', :profile => @profile)
    @proposal.created_by = @person
  end

  attr_reader :profile, :proposal, :person

  should 'save a proposal' do
    proposal.abstract = 'abstract'
    assert proposal.save
  end

  should 'do not save a proposal without abstract' do
    proposal.save
    assert proposal.errors['abstract'].present?
  end

  should 'allow edition if user is the author' do
    assert proposal.allow_edit?(person)
  end

  should 'do not allow edition if user is not the author' do
    assert !proposal.allow_edit?(fast_create(Person))
  end

  should 'return body when to_html was called with feed=true' do
    assert_equal proposal.body, proposal.to_html(:feed => true)
  end

  should 'return a proc when to_html was called with feed=false' do
    assert proposal.to_html(:feed => false).kind_of?(Proc)
  end

  should 'return a proc when to_html was called with no feed parameter' do
    assert proposal.to_html.kind_of?(Proc)
  end

  should 'return proposals by discussion' do
    discussion = fast_create(ProposalsDiscussionPlugin::Discussion)
    topic = fast_create(ProposalsDiscussionPlugin::Topic, :parent_id => discussion.id)
    proposal1 = fast_create(ProposalsDiscussionPlugin::Proposal, :parent_id => topic.id)
    proposal2 = fast_create(ProposalsDiscussionPlugin::Proposal)
    proposal3 = fast_create(ProposalsDiscussionPlugin::Proposal, :parent_id => topic.id)

    assert_equivalent [proposal1, proposal3], ProposalsDiscussionPlugin::Proposal.from_discussion(discussion)
  end

end
