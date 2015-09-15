class ProposalsDiscussionPlugin::API < Grape::API

  resource :proposals_discussion_plugin do

    paginate per_page: 10, max_per_page: 20
    get ':id/ranking' do
      article = find_article(environment.articles, params[:id])
      current_page = paginate(article.ranking)
      #FIXME find a better way to get updated_at date
      {:proposals => current_page, :updated_at => current_page.blank? ? DateTime.now : current_page.first.updated_at}
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
