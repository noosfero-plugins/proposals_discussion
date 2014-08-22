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

end
