class ProposalsDiscussionPlugin::API < Grape::API

  resource :proposals_discussion_plugin do

    get ':id/ranking' do
      article = find_article(environment.articles, params[:id])
      Rails.cache.fetch("#{article.cache_key}/proposals_ranking", expires_in: 10.minutes) do
        max_hits = article.proposals.maximum(:hits)
        min_hits = article.proposals.minimum(:hits)

        proposals = article.proposals.map do |proposal|
          w = [(proposal.hits - max_hits).abs, (proposal.hits - min_hits).abs].max.to_f
          effective_support = (proposal.votes_for - proposal.votes_against)/w

          {:id => proposal.id, :abstract => proposal.abstract, :votes_for => proposal.votes_for, :votes_against => proposal.votes_against, :hits => proposal.hits, :effective_support => effective_support}
        end
        proposals = proposals.sort_by { |p| p[:effective_support] }.reverse
        {:proposals => proposals, :updated_at => DateTime.now}
      end
    end

  end

end
