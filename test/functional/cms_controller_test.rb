require File.dirname(__FILE__) + '/../test_helper'

class CmsControllerTest < ActionController::TestCase

  def setup
    @profile = fast_create(Community)

    @discussion = ProposalsDiscussionPlugin::Discussion.create!(:name => 'test', :profile => @profile)
    @topic = ProposalsDiscussionPlugin::Topic.create!(:name => 'test', :profile => @profile, :parent => @discussion)
    @proposal = ProposalsDiscussionPlugin::Proposal.create!(:name => 'test', :profile => @profile, :parent => @topic, :abstract => "Abstract", :body => "Proposal Body")

    user = create_user('testinguser')
    @profile.add_admin(user.person)
    login_as(user.login)
  end

  attr_reader :profile, :proposal, :topic, :discussion

  should 'display custom body label when edit a proposal' do
    discussion.custom_body_label = "My Custom Label"
    discussion.save!
    get :edit, :id => proposal.id, :profile => profile.identifier
    assert_tag :tag => 'label', :attributes => {:class => 'formlabel'}, :content => 'My Custom Label'
  end

  should 'escape html tags in custom body label' do
    discussion.custom_body_label = "My Custom <script>Label</script>"
    discussion.save!
    get :edit, :id => proposal.id, :profile => profile.identifier
    assert_tag :tag => 'label', :attributes => {:class => 'formlabel'}, :content => 'My Custom Label'
  end

  should 'display available phases when edit a proposal' do
    get :edit, :id => discussion.id, :profile => profile.identifier
    assert_tag :tag => 'select', :attributes => {:id => 'article_phase'}
  end

  should 'display moderate proposals config option' do
    get :edit, :id => discussion.id, :profile => profile.identifier
    assert_select '#article_moderate_proposals'
  end

end
