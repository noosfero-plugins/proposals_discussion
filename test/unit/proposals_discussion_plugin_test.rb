require File.dirname(__FILE__) + '/../test_helper'

class ProposalsDiscussionPluginTest < ActiveSupport::TestCase

  def setup
    @plugin = ProposalsDiscussionPlugin.new
    @profile = fast_create(Community)
    @params = {}
    @plugin.stubs(:context).returns(self)
  end

  attr_reader :plugin, :profile, :params

  should 'has stylesheet' do
    assert @plugin.stylesheet?
  end

  should 'return Discussion as a content type' do
    @params[:parent_id] = nil
    assert_includes plugin.content_types, ProposalsDiscussionPlugin::Discussion
  end

  should 'return Topic as a content type if parent is a Discussion' do
    parent = fast_create(ProposalsDiscussionPlugin::Discussion, :profile_id => @profile.id)
    @params[:parent_id] = parent.id
    assert_includes plugin.content_types, ProposalsDiscussionPlugin::Topic
  end

  should 'return Proposal as a content type if parent is a Topic' do
    parent = fast_create(ProposalsDiscussionPlugin::Topic, :profile_id => @profile.id)
    @params[:parent_id] = parent.id
    assert_includes plugin.content_types, ProposalsDiscussionPlugin::Proposal
  end

  should 'return Proposal as a content type if parent is a Discussion and allow_topic is false' do
    parent = ProposalsDiscussionPlugin::Discussion.create!(:profile => @profile, :name => 'discussion', :allow_topics => false)
    @params[:parent_id] = parent.id
    assert_includes plugin.content_types, ProposalsDiscussionPlugin::Proposal
  end

  should 'do not return Proposal as a content type if parent is nil' do
    @params[:parent_id] = nil
    assert_not_includes plugin.content_types, ProposalsDiscussionPlugin::Proposal
  end

  should 'remove new button from content page for a discussion' do
    page = fast_create(ProposalsDiscussionPlugin::Discussion, :profile_id => @profile.id)
    assert plugin.content_remove_new(page)
  end

  should 'remove upload button from content page for a discussion' do
    page = fast_create(ProposalsDiscussionPlugin::Discussion, :profile_id => @profile.id)
    assert plugin.content_remove_upload(page)
  end

  should 'remove new button from content page for a proposal' do
    page = fast_create(ProposalsDiscussionPlugin::Proposal, :profile_id => @profile.id)
    assert plugin.content_remove_new(page)
  end

  should 'remove upload button from content page for a proposal' do
    page = fast_create(ProposalsDiscussionPlugin::Proposal, :profile_id => @profile.id)
    assert plugin.content_remove_upload(page)
  end

  should 'do not remove new button from content page for others article types' do
    page = fast_create(Article, :profile_id => @profile.id)
    assert !plugin.content_remove_new(page)
  end

  should 'do not remove upload button from content page for others article types' do
    page = fast_create(Article, :profile_id => @profile.id)
    assert !plugin.content_remove_upload(page)
  end

end
