class ProposalsDiscussionPluginMyprofileController < MyProfileController

  before_filter :check_edit_permission_to_proposal, :only => :publish_proposal

  def select_topic
    @discussion = profile.articles.find(params[:parent_id])
    render :file => 'select_topic'
  end

  def new_proposal
    redirect_to :controller => 'cms', :action => 'new', :type => "ProposalsDiscussionPlugin::Proposal", :parent_id => params[:discussion][:topic]
  end

  def publish_proposal
    if @proposal.update_attribute(:published, true)
      session[:notice] = _('Proposal published!')
    else
      session[:notice] = _('Failed to publish your proposal.')
    end
    redirect_to @proposal.topic.view_url
  end

  protected

  def check_edit_permission_to_proposal
    @proposal = profile.articles.find(params[:proposal_id])
    render_access_denied unless @proposal.allow_edit?(user)
  end

end
