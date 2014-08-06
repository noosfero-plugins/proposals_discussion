class ProposalsDiscussionPlugin::Discussion < Folder

  has_many :topics, :class_name => 'ProposalsDiscussionPlugin::Topic', :foreign_key => 'parent_id'
  has_many :proposals, :class_name => 'ProposalsDiscussionPlugin::Proposal', :through => :children, :source => :children

  def self.short_description
    _("Discussion")
  end

  def self.description
    _('Container for topics.')
  end

  def to_html(options = {})
    proc do
      render :file => 'content_viewer/discussion'
    end
  end

end
