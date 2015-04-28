module ProposalsDiscussionPlugin::DiscussionHelper

  def link_to_new_proposal(discussion)
    return '' unless discussion.allow_new_proposals?

    url = {:discussion_id => discussion.id, :profile => discussion.profile.identifier}
    if discussion.allow_topics
      url.merge!(:controller => 'proposals_discussion_plugin_myprofile', :action => 'select_topic')
    else
      url.merge!(:controller => 'cms', :action => 'new', :type => "ProposalsDiscussionPlugin::Proposal")
    end
    link_to _("Send your proposal!"), url_for(url), :class => 'button with-text icon-add'
  end

  def discussion_phases(discussion)
    discussion.available_phases.map do |phase|
      active = discussion.phase.to_sym == phase.first ? ' active' : ''
      content_tag 'span', phase.second, :class => "phase #{phase.first}#{active}"
    end.join
  end

end
