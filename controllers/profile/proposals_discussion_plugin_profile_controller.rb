class ProposalsDiscussionPluginProfileController < ProfileController

  before_filter :check_access_to_profile

  def export
    @comments = @target.proposals_comments
  end

  protected

  def check_access_to_profile
    @target = profile.articles.find(params[:article_id])
    render_access_denied(_('You are not allowed to export data from this article')) unless @target.allow_create?(user)
  end

end
