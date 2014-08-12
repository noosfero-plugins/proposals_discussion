require File.dirname(__FILE__) + '/../test_helper'

class ProposalsDiscussionPluginPublicControllerTest < ActionController::TestCase

  def setup
    @profile = fast_create(Community)
    @discussion = fast_create(ProposalsDiscussionPlugin::Discussion, :profile_id => @profile.id)
    @topic = fast_create(ProposalsDiscussionPlugin::Topic, :parent_id => @discussion.id, :profile_id => @profile.id)
  end

  attr_reader :profile, :discussion, :topic

  should 'load proposals' do
    proposals = 3.times.map { fast_create(ProposalsDiscussionPlugin::Proposal, :name => 'proposal title', :abstract => 'proposal abstract', :profile_id => profile.id, :parent_id => topic.id)}
    get :load_proposals, :profile => profile.identifier, :holder_id => discussion.id
    assert_equivalent proposals, assigns(:proposals)
  end

  should 'add link to next page' do
    proposal = fast_create(ProposalsDiscussionPlugin::Proposal, :name => 'proposal title', :abstract => 'proposal abstract', :profile_id => profile.id, :parent_id => topic.id)
    get :load_proposals, :profile => profile.identifier, :holder_id => discussion.id
    assert_match /href=.*page=2/, response.body
  end

  should 'render blank text if it is the last page' do
    get :load_proposals, :profile => profile.identifier, :holder_id => discussion.id
    assert_equal '', response.body
  end

  should 'load proposals with alphabetical order' do
    proposal1 = fast_create(ProposalsDiscussionPlugin::Proposal, :name => 'z proposal', :abstract => 'proposal abstract', :profile_id => profile.id, :parent_id => topic.id)
    proposal2 = fast_create(ProposalsDiscussionPlugin::Proposal, :name => 'abc proposal', :abstract => 'proposal abstract', :profile_id => profile.id, :parent_id => topic.id)
    proposal3 = fast_create(ProposalsDiscussionPlugin::Proposal, :name => 'abd proposal', :abstract => 'proposal abstract', :profile_id => profile.id, :parent_id => topic.id)
    get :load_proposals, :profile => profile.identifier, :holder_id => discussion.id, :order => 'alphabetical'
    assert_equal [proposal2, proposal3, proposal1], assigns(:proposals)
  end

end
