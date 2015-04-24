class ProposalsDiscussionPlugin::Story < TinyMceArticle

  validates_presence_of :abstract

  def self.short_description
    _("Story")
  end

  def self.description
    _("Discussion Story")
  end

end

