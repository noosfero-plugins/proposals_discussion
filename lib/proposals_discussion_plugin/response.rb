class ProposalsDiscussionPlugin::Response < TinyMceArticle

  validates_presence_of :body

  validate :check_parent_type

  before_save do |article|

    article.parent.setting[:replied] = true
    article.parent.save!

    article.parent.parent.setting[:replied] = true
    article.parent.parent.save!
  end

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

end
