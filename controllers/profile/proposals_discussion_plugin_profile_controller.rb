class ProposalsDiscussionPluginProfileController < ProfileController

  def export
    @comments = profile.articles.find(params[:article_id]).proposals_comments
  end

end
