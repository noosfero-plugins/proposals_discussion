class ProposalsDiscussionPlugin::Discussion < ProposalsDiscussionPlugin::ProposalsHolder

  has_many :topics, :class_name => 'ProposalsDiscussionPlugin::Topic', :foreign_key => 'parent_id'
  has_many :topics_proposals, :class_name => 'ProposalsDiscussionPlugin::Proposal', :through => :children, :source => :children
  has_many :topics_proposals_comments, :class_name => 'Comment', :through => :topics_proposals, :source => :comments
  has_many :discussion_proposals, :class_name => 'ProposalsDiscussionPlugin::Proposal', :foreign_key => 'parent_id'
  has_many :discussion_proposals_comments, :class_name => 'Comment', :through => :discussion_proposals, :source => :comments
  has_many :proposals_authors, :class_name => 'Person', :through => :children, :source => :created_by

  def proposals
    allow_topics ? topics_proposals : discussion_proposals
  end

  def proposals_comments
    allow_topics ? topics_proposals_comments : discussion_proposals_comments
  end

  settings_items :custom_body_label, :type => :string, :default => _('Body')
  settings_items :allow_topics, :type => :boolean, :default => true
  settings_items :phase, :type => :string, :default => :proposals

  attr_accessible :custom_body_label, :allow_topics, :phase

  AVAILABLE_PHASES = {:proposals => _('Proposals'), :vote => 'Vote', :finish => 'Announcement'}

  def self.short_description
    _("Discussion")
  end

  def self.description
    _('Container for topics.')
  end

  def available_phases
    AVAILABLE_PHASES
  end

  def allow_new_proposals?
    phase.to_sym == :proposals
  end

  def to_html(options = {})
    discussion = self
    proc do
      if discussion.allow_topics
        render :file => 'content_viewer/discussion_topics', :locals => {:discussion => discussion}
      else
        render :file => 'content_viewer/discussion', :locals => {:discussion => discussion}
      end
    end
  end

  def posts
    #override posts method to list proposals in feed
    ProposalsDiscussionPlugin::Proposal.from_discussion(self)
  end

end
