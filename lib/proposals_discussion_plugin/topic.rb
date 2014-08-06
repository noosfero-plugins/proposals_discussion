class ProposalsDiscussionPlugin::Topic < Folder

  alias :discussion :parent
  alias :proposals :children

  has_many :proposals_comments, :class_name => 'Comment', :through => :children, :source => :comments
  has_many :proposals_authors, :class_name => 'Person', :through => :children, :source => :created_by

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
      render :file => 'content_viewer/topic'
    end
  end

  def allow_create?(user)
    true
  end

end
