require_relative '../test_helper'
require_relative '../../../../test/unit/api/test_helper'

class APITest <  ActiveSupport::TestCase

  def setup
    login_api
    environment = Environment.default
    environment.enable_plugin(ProposalsDiscussionPlugin)
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
    process_delayed_job_queue

    get "/api/v1/proposals_discussion_plugin/#{topic.id}/ranking?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal [proposal2.abstract, proposal3.abstract, proposal1.abstract], json['proposals'].map {|p| p['abstract']}
    assert json['updated_at'].to_datetime <= Time.now
  end

  should 'suggest article children' do
    discussion = fast_create(ProposalsDiscussionPlugin::Discussion, :profile_id => user.person.id)
    topic = fast_create(ProposalsDiscussionPlugin::Topic, :profile_id => user.person.id, :parent_id => discussion.id)
    params[:article] = {:name => "Proposal name", :abstract => "Proposal abstract", :type => 'ProposalsDiscussionPlugin::Proposal'}
    assert_difference "ProposalsDiscussionPlugin::ProposalTask.count" do
      post "/api/v1/proposals_discussion_plugin/#{topic.id}/propose?#{params.to_query}"
    end
    json = JSON.parse(last_response.body)
    assert json['success']
  end

  should 'sanitize proposal' do
    discussion = fast_create(ProposalsDiscussionPlugin::Discussion, :profile_id => user.person.id)
    topic = fast_create(ProposalsDiscussionPlugin::Topic,
      :profile_id => user.person.id,
      :parent_id => discussion.id)
    params[:article] = {:name => "Proposal name", :abstract => "Proposal <iframe>Test</iframe> abstract",
      :type => 'ProposalsDiscussionPlugin::Proposal',
      :body => "This is a malicious body <iMg SrC=x OnErRoR=document.documentElement.innerHTML=1>SearchParam"}
    assert_difference "ProposalsDiscussionPlugin::ProposalTask.count" do
      post "/api/v1/proposals_discussion_plugin/#{topic.id}/propose?#{params.to_query}"
    end
    json = JSON.parse(last_response.body)
    assert json['success']
    task = Task.last
    assert_equal "Proposal Test abstract", task.abstract
    assert_equal "This is a malicious body SearchParam", task.article.body
  end

  should 'return article position when list proposals' do
    discussion = fast_create(ProposalsDiscussionPlugin::Discussion, :profile_id => user.person.id)
    topic = fast_create(ProposalsDiscussionPlugin::Topic, :profile_id => user.person.id, :parent_id => discussion.id)
    proposal = fast_create(ProposalsDiscussionPlugin::Proposal, :profile_id => user.person.id, :parent_id => topic.id)
    params[:content_type] = 'ProposalsDiscussionPlugin::Proposal'
    topic.update_ranking

    get "/api/v1/articles/?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_includes json["articles"].map { |a| a["ranking_position"] }, 1
  end

  should 'check if a proposal and their topic was replied' do
    discussion = create(ProposalsDiscussionPlugin::Discussion, :name => 'Discussion', :profile_id => user.person.id)
    topic = create(ProposalsDiscussionPlugin::Topic, :name => 'Topic', :profile_id => user.person.id, :parent_id => discussion.id)
    proposal = create(ProposalsDiscussionPlugin::Proposal, :name => 'Proposal', :abstract => 'This is a proposal', :body => 'test', :profile_id => user.person.id, :parent_id => topic.id)
    response = create(ProposalsDiscussionPlugin::Response, :name => 'Response', :body => 'test response', :profile_id => user.person.id, :parent_id => proposal.id)
    get "/api/v1/articles/#{topic.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)

    assert json["article"]["replied"]

    get "/api/v1/articles/#{topic.id}/children/#{proposal.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)

    assert json["article"]["replied"]
  end

end
