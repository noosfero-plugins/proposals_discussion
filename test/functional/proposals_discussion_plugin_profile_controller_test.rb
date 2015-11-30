require_relative '../test_helper'

class ProposalsDiscussionPluginProfileControllerTest < ActionController::TestCase

  def setup
    @profile = fast_create(Community)
    @discussion = ProposalsDiscussionPlugin::Discussion.create!(:profile => @profile, :name => 'discussion',:allow_topics => true)
    @topic = fast_create(ProposalsDiscussionPlugin::Topic, :parent_id => @discussion.id, :profile_id => @profile.id)
    @person = create_user_with_permission('testinguser', 'post_content', @profile)
    login_as :testinguser
  end

  attr_reader :profile, :discussion, :topic, :person

  should 'assigns comments of all proposals' do
    discussion.class.any_instance.stubs(:allow_create?).returns(true)
    proposal1 = fast_create(ProposalsDiscussionPlugin::Proposal, :profile_id => profile.id, :parent_id => topic.id)
    proposal2 = fast_create(ProposalsDiscussionPlugin::Proposal, :profile_id => profile.id, :parent_id => topic.id)
    comment1 = fast_create(Comment, :source_id => proposal1.id)
    comment2 = fast_create(Comment, :source_id => proposal1.id)
    comment3 = fast_create(Comment, :source_id => proposal2.id)
    get :export, :format => :csv, :article_id => discussion.id, :profile => profile.identifier
    assert_equivalent [comment1, comment2, comment3], assigns(:comments)
  end

  should 'deny access to export when user is not logged' do
    logout
    get :export, :format => :csv, :article_id => discussion.id, :profile => profile.identifier
    assert_template 'access_denied'
  end

  should 'deny access to export when user has no permission' do
    login_as(create_user('testuser').login)
    get :export, :format => :csv, :article_id => discussion.id, :profile => profile.identifier
    assert_template 'access_denied'
  end

end
