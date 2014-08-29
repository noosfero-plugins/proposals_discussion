class ProposalsDiscussionPlugin::Topic < Folder

  alias :discussion :parent

  has_many :proposals, :class_name => 'ProposalsDiscussionPlugin::Proposal', :foreign_key => 'parent_id'
  has_many :proposals_comments, :class_name => 'Comment', :through => :children, :source => :comments
  has_many :proposals_authors, :class_name => 'Person', :through => :children, :source => :created_by

  settings_items :color, :type => :string

  attr_accessible :color

  def self.short_description
    _("Discussion topic")
  end

  def self.description
    _('Container for proposals.')
  end

  def most_active_participants
    proposals_authors.group('profiles.id').order('count(articles.id) DESC').includes(:environment, :preferred_domain, :image)
  end

  def to_html(options = {})
    proc do
      render :file => 'content_viewer/topic', :locals => {:topic => @page}
    end
  end

  def allow_create?(user)
    true
  end

  def max_score
    @max ||= [1, proposals.maximum(:comments_count)].max
  end

  def proposal_tags
    proposals.tag_counts.inject({}) do |memo,tag|
      memo[tag.name] = tag.count
      memo
    end
  end

  def proposals_per_day
    proposals.group("date(created_at)").count
  end

  def comments_per_day
    proposals.joins(:comments).group('date(comments.created_at)').count('comments.id')
  end

  def cache_key_with_person(params = {}, user = nil, language = 'en')
    cache_key_without_person + (user ? "-#{user.identifier}" : '')
  end
  alias_method_chain :cache_key, :person

end
