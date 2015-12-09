class ProposalsDiscussionPlugin::Response < TinyMceArticle

  validates_presence_of :body

  validate :check_parent_type

  def self.short_description
    _("Proposal Response")
  end

  def self.description
    _("The response of a Proposal")
  end

  def icon_name
    'response'
  end

  protected

  def check_parent_type
    unless parent.is_a? ProposalsDiscussionPlugin::Proposal
      errors.add(:parent, N_('of Response needs be a Proposal'))
    end
  end

  def parent_archived?
    # skip parent archived validation for responses
    false
  end

end
