class ProposalsDiscussionPlugin::API < Grape::API

  resource :proposals_discussion_plugin do

    paginate per_page: 10, max_per_page: 20
    get ':id/ranking' do
      article = find_article(environment.articles, params[:id])
      ranking = Rails.cache.fetch("#{article.cache_key}/proposals_ranking", expires_in: 10.minutes) do
        max_hits = article.proposals.maximum(:hits)
        min_hits = article.proposals.minimum(:hits)

        proposals = article.proposals.map do |proposal|
          w = [(proposal.hits - max_hits).abs, (proposal.hits - min_hits).abs, 1].max.to_f
          effective_support = (proposal.votes_for - proposal.votes_against)/w

          {:id => proposal.id, :abstract => proposal.abstract, :votes_for => proposal.votes_for, :votes_against => proposal.votes_against, :hits => proposal.hits, :effective_support => effective_support}
        end
        proposals = proposals.sort_by { |p| p[:effective_support] }.reverse
        {:proposals => proposals, :updated_at => DateTime.now}
      end
      ranking[:proposals] = paginate ranking[:proposals]
      ranking
    end

    post ':id/propose' do
      parent_article = environment.articles.find(params[:id])

      proposal_task = ProposalsDiscussionPlugin::ProposalTask.new
      proposal_task.article = params[:article]
      proposal_task.article[:parent_id] = parent_article.id
      proposal_task.target = parent_article.profile
      proposal_task.requestor = current_person

      unless proposal_task.save
        render_api_errors!(proposal_task.article_object.errors.full_messages)
      end
      {:success => true}
      #present proposal_task, :with => Entities::Task, :fields => params[:fields]
    end

  end

end
