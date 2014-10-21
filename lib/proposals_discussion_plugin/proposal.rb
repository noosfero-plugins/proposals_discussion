class ProposalsDiscussionPlugin::Proposal < TinyMceArticle

  scope :private, lambda {|user| {:conditions => {:last_changed_by_id => user.id, :published => false}}}
  scope :from_discussion, lambda {|discussion| joins(:parent).where(['parents_articles.parent_id = ?', discussion.id])}

  alias :topic :parent

  def self.short_description
    _("Proposal")
  end

  def self.description
    _('Proposal')
  end

  validates_presence_of :abstract


  def to_html(options = {})
    proposal = self
    unless options[:feed]
      proc do
        render :file => 'content_viewer/proposal', :locals => {:proposal => proposal}
      end
    else
      body
    end
  end

  def allow_edit?(user)
    super || created_by == user
  end

  def score
    comments_count
  end

  def normalized_score(holder)
    (score/holder.max_score.to_f).round(2)
  end

  def cache_key_with_person(params = {}, user = nil, language = 'en')
    cache_key_without_person + (user && created_by == user ? "-#{user.identifier}" : '')
  end
  alias_method_chain :cache_key, :person

  def can_display_versions?
    false
  end

end
