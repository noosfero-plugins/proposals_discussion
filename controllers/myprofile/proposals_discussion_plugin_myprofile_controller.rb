class ProposalsDiscussionPluginMyprofileController < MyProfileController

  before_filter :check_edit_permission_to_proposal, :only => :publish_proposal
  before_filter :set_discussion, :only => [:select_topic, :new_proposal]

  def select_topic
  end

  def new_proposal
    if params[:discussion].blank? || params[:discussion][:topic].blank?
      session[:notice] = _('Please select a topic')
      render :file => 'proposals_discussion_plugin_myprofile/select_topic'
    else
      redirect_to :controller => 'cms', :action => 'new', :type => "ProposalsDiscussionPlugin::Proposal", :parent_id => params[:discussion][:topic]
    end
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

  def set_discussion
    @discussion = profile.articles.find(params[:parent_id])
  end

end
