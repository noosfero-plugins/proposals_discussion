class ProposalsDiscussionPlugin::ProposalsHolder < Folder

  has_many :proposals, :class_name => 'ProposalsDiscussionPlugin::Proposal', :foreign_key => 'parent_id'
  has_many :proposals_authors, :class_name => 'Person', :through => :children, :source => :created_by

  def accept_comments?
    accept_comments
  end

  def max_score
    @max ||= [1, proposals.maximum(:comments_count)].max
  end

  def proposals_per_day
    result = proposals.group("date(created_at)").count
    fill_empty_days(result)
  end

  def comments_per_day
    result = proposals.joins(:comments).group('date(comments.created_at)').count('comments.id')
    fill_empty_days(result)
  end

  def most_active_participants
    proposals_authors.group('profiles.id').order('count(articles.id) DESC').includes(:environment, :preferred_domain, :image)
  end

  def fill_empty_days(result)
    from = created_at.to_date
    (from..Date.today).inject({}) do |h, date|
      h[date.to_s] = result[date.to_s] || 0
      h
    end
  end

  def proposal_tags
    proposals.tag_counts.inject({}) do |memo,tag|
      memo[tag.name] = tag.count
      memo
    end
  end

  def ranking
    ProposalsDiscussionPlugin::RankingItem.joins(:proposal => :parent).where('parents_articles.id' => self.id)
  end

  def compute_ranking
    max_hits = proposals.maximum(:hits)
    min_hits = proposals.minimum(:hits)

    ranking = proposals.map do |proposal|
      w = [(proposal.hits - max_hits).abs, (proposal.hits - min_hits).abs, 1].max.to_f
      effective_support = (proposal.votes_for - proposal.votes_against)/w

      ProposalsDiscussionPlugin::RankingItem.new(:proposal => proposal, :abstract => proposal.abstract, :votes_for => proposal.votes_for, :votes_against => proposal.votes_against, :hits => proposal.hits, :effective_support => effective_support)
    end
    ranking.sort_by { |p| p.effective_support }.reverse
  end

  def update_ranking
    new_ranking = compute_ranking
    transaction do
      self.ranking.destroy_all
      new_ranking.each {|item| item.save!}
    end
  end

  def cache_key_with_person(params = {}, user = nil, language = 'en')
    cache_key_without_person + (user ? "-#{user.identifier}" : '')
  end
  alias_method_chain :cache_key, :person

end
