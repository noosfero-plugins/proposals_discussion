class ProposalsDiscussionPluginMyprofileController < MyProfileController

  def select_topic
    @discussion = profile.articles.find(params[:parent_id])
    render :file => 'select_topic'
  end

  def new_proposal
    redirect_to :controller => 'cms', :action => 'new', :type => "ProposalsDiscussionPlugin::Proposal", :parent_id => params[:discussion][:topic]
  end

end
