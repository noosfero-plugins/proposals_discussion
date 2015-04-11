class ProposalsDiscussionPlugin < Noosfero::Plugin

  def self.plugin_name
    'Discussion of Proposals'
  end

  def self.plugin_description
    _("Provide a structured way to promove a discussion over ideas proposed by users.")
  end

  def stylesheet?
    true
  end

  def content_types
    if context.respond_to?(:params) && context.params.kind_of?(Hash) && context.params[:controller] == 'cms' && context.params[:action] == 'new'
      types = []
      parent_id = context.params[:parent_id]
      parent = parent_id ? context.profile.articles.find(parent_id) : nil
      types << ProposalsDiscussionPlugin::Discussion
      types << ProposalsDiscussionPlugin::Topic if parent.kind_of?(ProposalsDiscussionPlugin::Discussion)
      types << ProposalsDiscussionPlugin::Proposal if parent.kind_of?(ProposalsDiscussionPlugin::Topic) || ( parent.kind_of?(ProposalsDiscussionPlugin::Discussion) && !parent.allow_topics)
      types
    else
      [ProposalsDiscussionPlugin::Discussion,
        ProposalsDiscussionPlugin::Topic,
        ProposalsDiscussionPlugin::Proposal]
    end
  end

  def content_remove_new(page)
    page.kind_of?(ProposalsDiscussionPlugin::Discussion) ||
      page.kind_of?(ProposalsDiscussionPlugin::Topic) ||
      page.kind_of?(ProposalsDiscussionPlugin::Proposal)
  end

  def content_remove_upload(page)
    page.kind_of?(ProposalsDiscussionPlugin::Discussion) ||
      page.kind_of?(ProposalsDiscussionPlugin::Topic) ||
      page.kind_of?(ProposalsDiscussionPlugin::Proposal)
  end

  def js_files
    ['jquery.jscroll.min.js', 'jquery.masonry.min.js', 'flotr2.min.js']
  end

  def self.extra_blocks
    {
      ProposalsDiscussionPlugin::ProposalsBlock => {}
    }
  end

end
