require_relative '../test_helper'

class RankingJobTest < ActiveSupport::TestCase

  def setup
    @job = ProposalsDiscussionPlugin::RankingJob.new
    @topic = fast_create(ProposalsDiscussionPlugin::Topic)
    @proposal = fast_create(ProposalsDiscussionPlugin::Proposal, :parent_id => topic.id)
  end

  attr_accessor :job, :topic, :proposal

  should 'create ranking job in initialization' do
    assert job.class.find_job.exists?
  end

  should 'do not create duplicated ranking job' do
    job.schedule
    job.schedule
    assert_equal 1, job.class.find_job.count
  end

  should 'schedule topic jobs when performed' do
    job.perform
    assert ProposalsDiscussionPlugin::RankingJob::TopicRankingJob.new(topic.id).find_job.exists?
  end

  should 'reschedule job when performed' do
    process_delayed_job_queue
    job.perform
    new_job = job.class.find_job.first
    assert new_job.present?
    assert new_job.run_at > 20.minutes.from_now
  end

  should 'schedule topic job' do
    topic_job = ProposalsDiscussionPlugin::RankingJob::TopicRankingJob.new(topic.id)
    topic_job.schedule
    assert topic_job.find_job.exists?
  end

  should 'do not schedule duplicated topic job' do
    topic_job = ProposalsDiscussionPlugin::RankingJob::TopicRankingJob.new(topic.id)
    topic_job.schedule
    topic_job.schedule
    assert_equal 1, topic_job.find_job.count
  end

  should 'perform topic job' do
    job.schedule
    assert_equal 0, topic.ranking.count
    process_delayed_job_queue
    assert_equal 1, topic.ranking.count
  end

end
