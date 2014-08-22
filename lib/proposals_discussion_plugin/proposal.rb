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

  def score
    comments_count
  end

  def normalized_score(holder)
    ((score - holder.min_score)/(holder.max_score - holder.min_score).to_f).round(2)
  end

end
