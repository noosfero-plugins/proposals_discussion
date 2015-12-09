require_relative '../test_helper'

class ResponseTest < ActiveSupport::TestCase

  def setup
    @profile = fast_create(Community)
    @person = fast_create(Person)
    @discussion = ProposalsDiscussionPlugin::Discussion.create!(:name => 'discussion', :profile => person, :allow_topics => false)
    @topic = ProposalsDiscussionPlugin::Topic.create!(:name => 'topic', :profile => person, :parent => @discussion)
    @proposal = ProposalsDiscussionPlugin::Proposal.create!(:name => 'test', :abstract => 'abstract', :profile => @profile, :parent => @topic)
  end

  attr_reader :profile, :proposal, :person, :discussion, :topic

  should 'accept response even if the topic is archived' do
    proposal.update_attribute(:archived, true)
    response = ProposalsDiscussionPlugin::Response.new(:name => 'response', :abstract => 'response', :body => 'body', :profile => profile, :parent => proposal)
    assert response.save
  end

end
