class ProposalsDiscussionPlugin::RankingJob

  def perform
    ProposalsDiscussionPlugin::Topic.find_each do |topic|
      ProposalsDiscussionPlugin::RankingJob::TopicRankingJob.new(topic.id).schedule
    end
  end

  def after(job)
    schedule(30.minutes.from_now)
  end

  def schedule(run_at = nil)
    Delayed::Job.enqueue(self, {:run_at => run_at}) unless self.class.find_job.exists?
  end

  def self.find_job
    Delayed::Job.by_handler("--- !ruby/object:ProposalsDiscussionPlugin::RankingJob {}\n").where('locked_at IS NULL')
  end


  class TopicRankingJob < Struct.new(:topic_id)

    def perform
      topic = ProposalsDiscussionPlugin::Topic.find_by_id(topic_id)
      topic.update_ranking if topic.present?
    end

    def schedule
      Delayed::Job.enqueue(self) unless find_job.exists?
    end

    def find_job
      Delayed::Job.by_handler("--- !ruby/struct:ProposalsDiscussionPlugin::RankingJob::TopicRankingJob\ntopic_id: #{topic_id}\n")
    end

  end

end
