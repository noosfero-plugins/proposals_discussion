class ProposalsDiscussionPlugin::API < Grape::API

  resource :proposals_discussion_plugin do

    paginate per_page: 10, max_per_page: 20
    get ':id/ranking' do
      article = find_article(environment.articles, params[:id])
      ranking = Rails.cache.fetch("#{article.cache_key}/proposals_ranking", expires_in: 30.minutes) do
        #FIXME call update_ranking in an async job
        article.update_ranking
        {:proposals => article.ranking, :updated_at => DateTime.now}
      end
      ranking[:proposals] = paginate ranking[:proposals]
      ranking
    end

    post ':id/propose' do
      sanitize_params_hash(params)

      parent_article = environment.articles.includes(:profile).find(params[:id])

      proposal_task = ProposalsDiscussionPlugin::ProposalTask.new
      proposal_task.article = params[:article]
      proposal_task.article_parent_id = parent_article.id
      proposal_task.article_parent = parent_article
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
