class ProposalsDiscussionPlugin::Proposal < TinyMceArticle

  def self.short_description
    _("Proposal")
  end

  def self.description
    _('Proposal')
  end

  validates_presence_of :abstract

end
