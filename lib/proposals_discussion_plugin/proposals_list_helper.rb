module ProposalsDiscussionPlugin::ProposalsListHelper

  def more_proposals(text, holder, order, page=1)
    link_to '', url_for({:controller => 'proposals_discussion_plugin_public', :action => 'load_proposals', :holder_id => holder.id, :profile => profile.identifier, :order => order, :page => page })
  end

end
