require File.dirname(__FILE__) + '/../test_helper'

class ProposalsDiscussionPluginMyprofileControllerTest < ActionController::TestCase

  def setup
    @profile = fast_create(Community)
    @discussion = fast_create(ProposalsDiscussionPlugin::Discussion, :profile_id => @profile.id)
    @topic = fast_create(ProposalsDiscussionPlugin::Topic, :parent_id => @discussion.id, :profile_id => @profile.id)
    @person = create_user_with_permission('testinguser', 'post_content')
    login_as :testinguser
  end

  attr_reader :profile, :discussion, :topic, :person

  should 'list topics for selection' do
    3.times {fast_create(ProposalsDiscussionPlugin::Topic, :parent_id => discussion.id, :profile_id => profile.id)}
    get :select_topic, :profile => profile.identifier, :discussion_id => discussion.id
    assert_equal discussion, assigns(:discussion)
    assert_select 'div#topics' do
      assert_select 'div.content', discussion.topics.count
      assert_select "input[name='parent_id']", discussion.topics.count
    end
    assert_tag :form, :attributes => {:action => "/myprofile/#{profile.identifier}/plugin/proposals_discussion/myprofile/new_proposal_with_topic?discussion_id=#{discussion.id}"}
  end

  should 'new_proposal redirect to cms controller' do
    get :new_proposal, :profile => profile.identifier,:parent_id => topic.id, :discussion_id => discussion.id
    assert_redirected_to :controller => 'cms', :action => 'new', :type => "ProposalsDiscussionPlugin::Proposal", :parent_id => topic.id
  end

  should 'publish a proposal' do
    proposal = fast_create(ProposalsDiscussionPlugin::Proposal, :parent_id => topic.id, :profile_id => profile.id, :published => false, :created_by_id => person.id)
    get :publish_proposal, :proposal_id => proposal.id, :profile => profile.identifier
    assert proposal.reload.published
  end

  should 'do not publish if the logged user do not have edition permission' do
    proposal = fast_create(ProposalsDiscussionPlugin::Proposal, :parent_id => topic.id, :profile_id => profile.id, :published => false)
    get :publish_proposal, :proposal_id => proposal.id, :profile => profile.identifier
    assert_response 403
    assert !proposal.reload.published
  end

  should 'new_proposal without a topic redirect to select_topic' do
    get :new_proposal_with_topic, :profile => profile.identifier, :discussion_id => discussion.id
    assert_template 'select_topic'
  end

end
