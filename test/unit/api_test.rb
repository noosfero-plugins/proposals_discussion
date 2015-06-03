require_relative '../test_helper'
require_relative '../../../../test/unit/api/test_helper'

class APITest <  ActiveSupport::TestCase

  def setup
    login_api
  end

  should 'return proposal ranking' do
    begin
      Environment.default.enable_plugin(VotePlugin)
    rescue
      puts 'VotePlugin not enabled'
      return
    end

    discussion = fast_create(ProposalsDiscussionPlugin::Discussion, :profile_id => user.person.id)
    topic = fast_create(ProposalsDiscussionPlugin::Topic, :profile_id => user.person.id, :parent_id => discussion.id)
    proposal1 = fast_create(ProposalsDiscussionPlugin::Proposal, :profile_id => user.person.id, :parent_id => topic.id)
    proposal2 = fast_create(ProposalsDiscussionPlugin::Proposal, :profile_id => user.person.id, :parent_id => topic.id)
    proposal3 = fast_create(ProposalsDiscussionPlugin::Proposal, :profile_id => user.person.id, :parent_id => topic.id)

    proposal2.update_attribute(:hits, 10)
    10.times { Vote.create!(:voteable => proposal2, :voter => nil, :vote => 1) }

    proposal3.update_attribute(:hits, 10)
    2.times { Vote.create!(:voteable => proposal3, :voter => nil, :vote => 1) }

    proposal1.update_attribute(:hits, 5)

    get "/api/v1/proposals_discussion_plugin/#{topic.id}/ranking?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal [proposal2.id, proposal3.id, proposal1.id], json['proposals'].map {|p| p['id']}
  end

  should 'suggest article children' do
    discussion = fast_create(ProposalsDiscussionPlugin::Discussion, :profile_id => user.person.id)
    topic = fast_create(ProposalsDiscussionPlugin::Topic, :profile_id => user.person.id, :parent_id => discussion.id)
    params[:article] = {:name => "Proposal name", :body => "Proposal body"}
    assert_difference "ProposalsDiscussionPlugin::ProposalTask.count" do
      post "/api/v1/proposals_discussion_plugin/#{topic.id}/propose?#{params.to_query}"
    end
    json = JSON.parse(last_response.body)
    assert json['success']
  end

end
