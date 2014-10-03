module ProposalsDiscussionPlugin::ProposalsListHelper

  def sort_criteria
    [[_('Random'), :random], [_('Alphabetical'), :alphabetical], [_('Recent'), :recent], [_('Most Commented'), :most_commented], [_('Most Recently Commented'), :most_recently_commented]]
  end

  def more_proposals(text, holder, order, page=1)
    link_to text, url_for({:controller => 'proposals_discussion_plugin_public', :action => 'load_proposals', :holder_id => holder.id, :profile => profile.identifier, :order => order, :page => page })
  end

end
