class ProposalsDiscussionPlugin::Topic  < ProposalsDiscussionPlugin::ProposalsHolder

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

  def to_html(options = {})
    topic = self
    proc do
      render :file => 'content_viewer/topic', :locals => {:topic => topic}
    end
  end

  def allow_create?(user)
    !discussion.moderate_proposals
  end

end
