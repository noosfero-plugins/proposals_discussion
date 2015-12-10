class ProposalsDiscussionPlugin::Topic  < ProposalsDiscussionPlugin::ProposalsHolder

  alias :discussion :parent

  has_many :proposals_comments, :class_name => 'Comment', :through => :children, :source => :comments

  settings_items :color, :type => :string
  settings_items :replied, :type => :boolean, :default => false

  attr_accessible :color

  def self.short_description
    _("Discussion topic")
  end

  def self.description
    _('Container for proposals.')
  end

  def to_html(options = {})
    topic = self
    proc do
      render :file => 'content_viewer/topic', :locals => {:topic => topic}
    end
  end

  def allow_create?(user)
    !discussion.moderate_proposals
  end

  def display_media_panel?
    true
  end

end
