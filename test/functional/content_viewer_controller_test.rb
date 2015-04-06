require File.dirname(__FILE__) + '/../test_helper'

class ContentViewerControllerTest < ActionController::TestCase

  def setup
    @profile = fast_create(Community)
    @person = fast_create(Person)
    @discussion = ProposalsDiscussionPlugin::Discussion.create!(:name => 'test', :profile => @profile)
    @topic = ProposalsDiscussionPlugin::Topic.create!(:name => 'test', :profile => @profile, :parent => @discussion)
    @proposal = ProposalsDiscussionPlugin::Proposal.create!(:name => 'test', :profile => @profile, :parent => @topic, :abstract => "Abstract", :body => "Proposal Body")
  end

  attr_reader :profile, :proposal, :topic, :discussion, :person

  should 'display custom proposal page' do
    get :view_page, proposal.url
    assert_tag :tag => 'div', :attributes => {:class => 'content'}, :content => 'Abstract'
    assert_tag :tag => 'div', :attributes => {:class => 'content'}, :content => 'Proposal Body'
  end

  should 'display discussion with topics' do
    discussion.allow_topics = true
    discussion.save!
    get :view_page, discussion.url
    assert_template 'content_viewer/discussion_topics'
  end

  should 'display discussion without topics' do
    discussion.allow_topics = false
    discussion.save!
    get :view_page, discussion.url
    assert_template 'content_viewer/discussion'
  end

  should 'do not load class proposals-discussion-infinite-scroll when listing topics' do
    discussion.allow_topics = true
    proposals = fast_create(ProposalsDiscussionPlugin::Proposal, :name => 'proposal title', :abstract => 'proposal abstract', :profile_id => profile.id, :parent_id => topic.id, :author_id => person.id)
    get :view_page, discussion.url
    assert_no_tag :tag => "div", :attributes => { :class => "proposals-discussion-infinite-scroll" }
  end

  should 'load class proposals-discussion-infinite-scroll when listing topics' do
    discussion.allow_topics = true
    proposals = fast_create(ProposalsDiscussionPlugin::Proposal, :name => 'proposal title', :abstract => 'proposal abstract', :profile_id => profile.id, :parent_id => topic.id, :author_id => person.id)
    get :view_page, topic.url
    assert_tag :tag => "div", :attributes => { :class => "proposals-discussion-infinite-scroll" }
  end


end
