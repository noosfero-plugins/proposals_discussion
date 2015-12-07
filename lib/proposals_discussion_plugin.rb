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
      parent_id = context.params[:parent_id] || (context.params[:article][:parent_id] unless context.params[:article].nil?)
      parent = parent_id.present? ? context.profile.articles.find(parent_id) : nil
      types << ProposalsDiscussionPlugin::Discussion
      types << ProposalsDiscussionPlugin::Topic if parent.kind_of?(ProposalsDiscussionPlugin::Discussion)
      if parent.kind_of?(ProposalsDiscussionPlugin::Topic) || ( parent.kind_of?(ProposalsDiscussionPlugin::Discussion) && !parent.allow_topics)
        types << ProposalsDiscussionPlugin::Proposal
        types << ProposalsDiscussionPlugin::Story
      end
      if parent.kind_of?(ProposalsDiscussionPlugin::Proposal)
        types << ProposalsDiscussionPlugin::Response
      end
      types
    else
      [ProposalsDiscussionPlugin::Discussion,
        ProposalsDiscussionPlugin::Topic,
        ProposalsDiscussionPlugin::Proposal,
        ProposalsDiscussionPlugin::Story]
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

  def self.api_mount_points
    [ProposalsDiscussionPlugin::API]
  end

  def extra_content_actions(article)
    proc do
      if article.kind_of? ProposalsDiscussionPlugin::Proposal
        render :partial => 'proposals_discussion/view_item_buttons', :locals => {:article => article}
      end
    end
  end

  # schedule ranking job in initialization process
  ProposalsDiscussionPlugin::RankingJob.new.schedule

end
