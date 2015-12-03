class ProposalsDiscussionPlugin::Response < TinyMceArticle

  validates_presence_of :body

  validate :check_parent_type

  def self.short_description
    _("Proposal Response")
  end

  def self.description
    _("The response of a Proposal")
  end

  protected

  def check_parent_type
    unless parent.is_a? ProposalsDiscussionPlugin::Proposal
      errors.add(:parent, N_('of Response needs be a Proposal'))
    end

    # if self.body_changed? && (self.changed & attrs_validators).any?
    #   errors.add(:response, N_('only have "body" field'))
    # end
  end

end
