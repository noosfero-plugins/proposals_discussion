require_relative '../test_helper'

class DiscussionHelperTest < ActionView::TestCase

  def setup
    @profile = fast_create(Community)
    @discussion = ProposalsDiscussionPlugin::Discussion.create!(:name => 'discussion', :profile => @profile, :name => 'discussion')
  end

  include ProposalsDiscussionPlugin::DiscussionHelper

  attr_reader :profile, :discussion

  should 'display new proposal link when discussion is in proposals phase' do
    assert !link_to_new_proposal(discussion).blank?
  end

  should 'not display new proposal link when discussion is in vote phase' do
    discussion.update_attribute(:phase, :vote)
    assert link_to_new_proposal(discussion).blank?
  end

  should 'not display new proposal link when discussion is in finish phase' do
    discussion.update_attribute(:phase, :finish)
    assert link_to_new_proposal(discussion).blank?
  end

end
