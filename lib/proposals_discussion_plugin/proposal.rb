class ProposalsDiscussionPlugin::Proposal < TinyMceArticle

  scope :private_proposal, lambda {|user| {:conditions => {:last_changed_by_id => user.id, :published => false}}}
  scope :from_discussion, lambda {|discussion| joins(:parent).where(['parents_articles.parent_id = ?', discussion.id])}

  belongs_to :topic, :foreign_key => :parent_id, :class_name => 'ProposalsDiscussionPlugin::Topic'

  has_many :locations, :class_name => 'Region', :through => :article_categorizations, :source => :category

  has_one :ranking_item

  def self.short_description
    _("Proposal")
  end

  def self.description
    _('Proposal')
  end

  before_create do |article|
    article.published = true
  end

  validates_presence_of :abstract

  validate :discussion_phase_proposals

  def discussion_phase_proposals
    errors.add(:base, _("Can't create a proposal at this phase.")) unless discussion.allow_new_proposals?
  end

  def allow_vote?
    discussion.phase.to_sym != :finish
  end

  def discussion
    @discussion ||= parent.kind_of?(ProposalsDiscussionPlugin::Discussion) ? parent : parent.discussion
  end

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

  def normalized_score
    (score/parent.max_score.to_f).round(2)
  end

  def cache_key_with_person(params = {}, user = nil, language = 'en')
    cache_key_without_person + (user && created_by == user ? "-#{user.identifier}" : '')
  end
  alias_method_chain :cache_key, :person

  def can_display_versions?
    false
  end

end
