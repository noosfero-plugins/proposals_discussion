class ProposalsDiscussionPlugin::API < Grape::API

  resource :proposals_discussion_plugin do

    get ':id/ranking' do
      article = find_article(environment.articles, params[:id])
      proposals = article.proposals.map do |proposal|
        effective_support = (proposal.votes_for - proposal.votes_against)/proposal.hits.to_f
        effective_participation = (proposal.votes_for + proposal.votes_against)/proposal.hits.to_f

        {:id => proposal.id, :abstract => proposal.abstract, :votes_for => proposal.votes_for, :votes_against => proposal.votes_against, :hits => proposal.hits, :effective_support => effective_support, :effective_participation => effective_participation}
      end

      proposals = proposals.sort_by { |p| p[:effective_support] }.reverse
      {:proposals => proposals, :updated_at => DateTime.now}
    end

  end

end
