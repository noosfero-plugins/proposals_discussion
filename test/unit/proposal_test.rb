require_relative '../test_helper'

class ProposalTest < ActiveSupport::TestCase

  def setup
    @profile = fast_create(Community)
    @person = fast_create(Person)
    @discussion = ProposalsDiscussionPlugin::Discussion.create!(:name => 'discussion', :profile => person, :allow_topics => false)
    @proposal = ProposalsDiscussionPlugin::Proposal.new(:name => 'test', :abstract => 'abstract', :profile => @profile, :parent => @discussion)
    @proposal.created_by = @person
  end

  attr_reader :profile, :proposal, :person, :discussion

  should 'save a proposal' do
    proposal.abstract = 'abstract'
    assert proposal.save
  end

  should 'do not save a proposal without abstract' do
    proposal.abstract = nil
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
    topic = fast_create(ProposalsDiscussionPlugin::Topic, :parent_id => discussion.id)
    proposal1 = fast_create(ProposalsDiscussionPlugin::Proposal, :parent_id => topic.id)
    proposal2 = fast_create(ProposalsDiscussionPlugin::Proposal)
    proposal3 = fast_create(ProposalsDiscussionPlugin::Proposal, :parent_id => topic.id)

    assert_equivalent [proposal1, proposal3], ProposalsDiscussionPlugin::Proposal.from_discussion(discussion)
  end

  should 'return discussion associated with a proposal' do
    assert_equal discussion, proposal.discussion
  end

  should 'return discussion associated with a proposal topic' do
    topic = fast_create(ProposalsDiscussionPlugin::Topic, :parent_id => discussion.id)
    proposal = fast_create(ProposalsDiscussionPlugin::Proposal, :parent_id => topic.id)
    assert_equal discussion, proposal.discussion
  end

  should 'return normalized score' do
    proposal1 = ProposalsDiscussionPlugin::Proposal.create!(:parent => discussion, :profile => profile, :name => "proposal1", :abstract => 'abstract')
    proposal2 = ProposalsDiscussionPlugin::Proposal.create!(:parent => discussion, :profile => profile, :name => "proposal2", :abstract => 'abstract')
    10.times { Comment.create!(:source => proposal1, :body => "comment", :author => person) }
    5.times { Comment.create!(:source => proposal2, :body => "comment", :author => person) }
    assert_equal 1, proposal1.reload.normalized_score
    assert_equal 0.5, proposal2.reload.normalized_score
  end

  should 'create a new proposal if the current phase is proposals' do
    discussion.update_attribute(:phase, :proposals)
    assert proposal.save
  end

  should 'do not create a new proposal if the current phase is vote' do
    discussion.update_attribute(:phase, :vote)
    assert !proposal.save
  end

  should 'do not create a new proposal if the current phase is finish' do
    discussion.update_attribute(:phase, :finish)
    assert !proposal.save
  end

  should 'do not create a new proposal if the current phase is invalid' do
    discussion.update_attribute(:phase, '')
    assert !proposal.save
  end

  should 'do not update a proposal if a discussion is not in proposals phase' do
    discussion.update_attribute(:phase, :vote)
    proposal.body = "changed"
    assert !proposal.save
  end

  should 'allow update of proposals if a discussion is in proposals phase' do
    proposal.body = "changed"
    assert proposal.save
  end

  should 'allow vote if discussion phase is vote' do
    discussion.update_attribute(:phase, :vote)
    assert proposal.allow_vote?
  end

  should 'allow vote if discussion phase is proposals' do
    discussion.update_attribute(:phase, :proposals)
    assert proposal.allow_vote?
  end

  should 'not allow vote if discussion phase is finish' do
    discussion.update_attribute(:phase, :finish)
    assert !proposal.allow_vote?
  end

  should 'set a proposal location' do
    location = fast_create(Region)
    proposal.save!
    proposal.add_category(location)
    assert_equal [location], proposal.locations
  end

  should 'add a response to a proposal' do
    proposal.save!
    data = {
      :name => 'Response',
      :body => 'A response test',
      :abstract => 'Test',
      :parent => proposal,
      :profile => profile
    }

    response = create(ProposalsDiscussionPlugin::Response, data)
    response.save!

    assert_equal proposal.id, response.parent.id
  end

  should 'not add a response to a proposal without a body' do
    proposal.save!
    data = {
      :name => 'Response',
      :abstract => 'Test',
      :parent => proposal,
      :profile => profile
    }

    err = assert_raises ActiveRecord::RecordInvalid do
      response = create(ProposalsDiscussionPlugin::Response, data)
    end

    assert_match "Body can't be blank", err.message
  end

  should 'not add a response to a article that isnt a proposal' do
    article = create(Article, :name => 'test article', :profile => @profile)
    data = {
      :name => 'Response',
      :abstract => 'Test',
      :parent => article,
      :profile => profile
    }

    err = assert_raises ActiveRecord::RecordInvalid do
      response = create(ProposalsDiscussionPlugin::Response, data)
    end

    assert_match "Parent of Response needs be a Proposal", err.message
  end

  should 'inherit categories from parent when save' do
    c1 = fast_create(Category)
    c2 = fast_create(Category)
    proposal.categories << c1
    discussion.categories << c2
    proposal.save!
    assert_equivalent [c1, c2], proposal.categories
  end

end
