class ProposalsDiscussionPlugin::Discussion < Folder

  acts_as_having_posts

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
    discussion = self
    proc do
      render :file => 'content_viewer/discussion', :locals => {:discussion => discussion}
    end
  end

  def cache_key_with_person(params = {}, user = nil, language = 'en')
    cache_key_without_person + (user ? "-#{user.identifier}" : '')
  end
  alias_method_chain :cache_key, :person

  def posts
    #override posts method to list proposals in feed
    ProposalsDiscussionPlugin::Proposal.from_discussion(self)
  end

end
