class ProposalsDiscussionPlugin::Proposal < TinyMceArticle

  scope :private, lambda {|user| {:conditions => {:last_changed_by_id => user.id, :published => false}}}

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

  def allow_edit?(user)
    super || created_by == user
  end

end
