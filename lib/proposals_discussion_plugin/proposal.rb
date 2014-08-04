class ProposalsDiscussionPlugin::Proposal < TinyMceArticle

  alias :topic :parent

  def self.short_description
    _("Proposal")
  end

  def self.description
    _('Proposal')
  end

  validates_presence_of :abstract


  def to_html(options = {})
    proc do
      render :file => 'content_viewer/proposal'
    end
  end

end
