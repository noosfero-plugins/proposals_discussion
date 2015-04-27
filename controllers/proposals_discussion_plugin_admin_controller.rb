class ProposalsDiscussionPluginAdminController < PluginAdminController

  def index
    @settings = Noosfero::Plugin::Settings.new(environment, ProposalsDiscussionPlugin, params[:settings])

    if request.post?
      @settings.save!
      session[:notice] = _('Settings succefully saved.')
      redirect_to :action => 'index'
    end
  end

end
