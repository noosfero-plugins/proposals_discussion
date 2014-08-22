class ProposalsDiscussionPlugin::Discussion < Folder

  has_many :topics, :class_name => 'ProposalsDiscussionPlugin::Topic', :foreign_key => 'parent_id'
  has_many :proposals, :class_name => 'ProposalsDiscussionPlugin::Proposal', :through => :children, :source => :children

  settings_items :custom_body_label, :type => :string, :default => _('Body')

  attr_accessible :custom_body_label

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
