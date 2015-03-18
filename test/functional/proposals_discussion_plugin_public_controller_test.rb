require File.dirname(__FILE__) + '/../test_helper'

class ProposalsDiscussionPluginPublicControllerTest < ActionController::TestCase

  def setup
    @person = fast_create(Person)
    @profile = fast_create(Community)
    @discussion = ProposalsDiscussionPlugin::Discussion.create!(:profile => @profile, :allow_topics => true, :name => 'discussion')
    @topic = fast_create(ProposalsDiscussionPlugin::Topic, :parent_id => @discussion.id, :profile_id => @profile.id)
  end

  attr_reader :profile, :discussion, :topic, :person

  should 'load proposals' do
    proposals = 3.times.map { fast_create(ProposalsDiscussionPlugin::Proposal, :name => 'proposal title', :abstract => 'proposal abstract', :profile_id => profile.id, :parent_id => topic.id, :author_id => person.id)}
    get :load_proposals, :profile => profile.identifier, :holder_id => topic.id
    assert_equivalent proposals, assigns(:proposals)
  end

  should 'add link to next page' do
    proposal = fast_create(ProposalsDiscussionPlugin::Proposal, :name => 'proposal title', :abstract => 'proposal abstract', :profile_id => profile.id, :parent_id => topic.id, :author_id => person.id)
    get :load_proposals, :profile => profile.identifier, :holder_id => topic.id
    assert_match /href=.*page=2/, response.body
  end

  should 'not render more link if it was the last page' do
    get :load_proposals, :profile => profile.identifier, :holder_id => topic.id
    assert_select 'div.more a', 0
  end

  should 'load proposals with alphabetical order' do
    proposal1 = fast_create(ProposalsDiscussionPlugin::Proposal, :name => 'z proposal', :abstract => 'proposal abstract', :profile_id => profile.id, :parent_id => topic.id, :author_id => person.id)
    proposal2 = fast_create(ProposalsDiscussionPlugin::Proposal, :name => 'abc proposal', :abstract => 'proposal abstract', :profile_id => profile.id, :parent_id => topic.id, :author_id => person.id)
    proposal3 = fast_create(ProposalsDiscussionPlugin::Proposal, :name => 'abd proposal', :abstract => 'proposal abstract', :profile_id => profile.id, :parent_id => topic.id, :author_id => person.id)
    get :load_proposals, :profile => profile.identifier, :holder_id => topic.id, :order => 'alphabetical'
    assert_equal [proposal2, proposal3, proposal1], assigns(:proposals)
  end

  should 'load proposals with most commented order' do
    proposal1 = fast_create(ProposalsDiscussionPlugin::Proposal, :name => 'proposal1', :abstract => 'proposal abstract', :profile_id => profile.id, :parent_id => topic.id, :author_id => person.id)
    proposal2 = fast_create(ProposalsDiscussionPlugin::Proposal, :name => 'proposal2', :abstract => 'proposal abstract', :profile_id => profile.id, :parent_id => topic.id, :author_id => person.id)
    proposal3 = fast_create(ProposalsDiscussionPlugin::Proposal, :name => 'proposal3', :abstract => 'proposal abstract', :profile_id => profile.id, :parent_id => topic.id, :author_id => person.id)

    author = fast_create(Person)
    Comment.create!(:source => proposal2, :body => 'text', :author => author)
    Comment.create!(:source => proposal2, :body => 'text', :author => author)
    Comment.create!(:source => proposal3, :body => 'text', :author => author)

    get :load_proposals, :profile => profile.identifier, :holder_id => topic.id, :order => 'most_commented'
    assert_equal [proposal2, proposal3, proposal1], assigns(:proposals)
  end

  should 'load proposals with most recent order' do
    proposal1 = fast_create(ProposalsDiscussionPlugin::Proposal, :name => 'z', :abstract => 'proposal abstract', :profile_id => profile.id, :parent_id => topic.id, :created_at => Date.today - 2.day, :author_id => person.id)
    proposal2 = fast_create(ProposalsDiscussionPlugin::Proposal, :name => 'b', :abstract => 'proposal abstract', :profile_id => profile.id, :parent_id => topic.id, :created_at => Date.today - 1.day, :author_id => person.id)
    proposal3 = fast_create(ProposalsDiscussionPlugin::Proposal, :name => 'k', :abstract => 'proposal abstract', :profile_id => profile.id, :parent_id => topic.id, :created_at => Date.today, :author_id => person.id)

    author = fast_create(Person)

    get :load_proposals, :profile => profile.identifier, :holder_id => topic.id, :order => 'recent'
    assert_equal [proposal3, proposal2, proposal1].map(&:name), assigns(:proposals).map(&:name)
  end

  should 'load proposals with most recently commented order' do
    proposal1 = fast_create(ProposalsDiscussionPlugin::Proposal, :name => 'proposal1', :abstract => 'proposal abstract', :profile_id => profile.id, :parent_id => topic.id, :author_id => person.id)
    proposal2 = fast_create(ProposalsDiscussionPlugin::Proposal, :name => 'proposal2', :abstract => 'proposal abstract', :profile_id => profile.id, :parent_id => topic.id, :author_id => person.id)
    proposal3 = fast_create(ProposalsDiscussionPlugin::Proposal, :name => 'proposal3', :abstract => 'proposal abstract', :profile_id => profile.id, :parent_id => topic.id, :author_id => person.id)

    author = fast_create(Person)
    Comment.create!({:source => proposal2, :body => 'text', :author => author, :created_at => 10.days.ago}, :without_protection => true)
    Comment.create!({:source => proposal2, :body => 'text', :author => author, :created_at => 10.days.ago}, :without_protection => true)
    Comment.create!(:source => proposal3, :body => 'text', :author => author)
    Comment.create!(:source => proposal3, :body => 'text', :author => author)
    Comment.create!(:source => proposal1, :body => 'text', :author => author)

    get :load_proposals, :profile => profile.identifier, :holder_id => topic.id, :order => 'most_recently_commented'
    assert_equal [proposal3, proposal1, proposal2], assigns(:proposals)
  end

  should 'load proposals when profile is private and the user is a member' do
    person = create_user.person
    login_as(person.identifier)
    profile.add_member(person)
    profile.update_attribute(:public_profile, false)

    proposals = 3.times.map { fast_create(ProposalsDiscussionPlugin::Proposal, :name => 'proposal title', :abstract => 'proposal abstract', :profile_id => profile.id, :parent_id => topic.id, :author_id => person.id)}
    get :load_proposals, :profile => profile.identifier, :holder_id => topic.id
    assert_equivalent proposals, assigns(:proposals)
  end

  should 'not load proposals when profile is private and user is not logged' do
    logout
    profile.update_attribute(:public_profile, false)
    proposals = 3.times.map { fast_create(ProposalsDiscussionPlugin::Proposal, :name => 'proposal title', :abstract => 'proposal abstract', :profile_id => profile.id, :parent_id => topic.id, :author_id => person.id)}
    get :load_proposals, :profile => profile.identifier, :holder_id => topic.id
    assert_equal nil, assigns(:proposals)
  end

end
