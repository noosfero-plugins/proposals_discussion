class ProposalsDiscussionPlugin::Discussion < Folder

  def self.short_description
    _("Discussion")
  end

  def self.description
    _('Container for proposals.')
  end

  def to_html(options = {})
    discussion = self
    proc do
      render :file => 'content_viewer/discussion', :locals => {:discussion => discussion}
    end
  end

end
