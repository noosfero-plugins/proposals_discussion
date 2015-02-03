require File.dirname(__FILE__) + '/../test_helper'

class ContentViewerControllerTest < ActionController::TestCase

  def setup
    @profile = fast_create(Community)

    @discussion = ProposalsDiscussionPlugin::Discussion.create!(:name => 'test', :profile => @profile)
    @topic = ProposalsDiscussionPlugin::Topic.create!(:name => 'test', :profile => @profile, :parent => @discussion)
    @proposal = ProposalsDiscussionPlugin::Proposal.create!(:name => 'test', :profile => @profile, :parent => @topic, :abstract => "Abstract", :body => "Proposal Body")
  end

  attr_reader :profile, :proposal, :topic, :discussion

  should 'display custom proposal page' do
    get :view_page, proposal.url
    assert_tag :tag => 'div', :attributes => {:class => 'content'}, :content => 'Abstract'
    assert_tag :tag => 'div', :attributes => {:class => 'content'}, :content => 'Proposal Body'
  end

end
