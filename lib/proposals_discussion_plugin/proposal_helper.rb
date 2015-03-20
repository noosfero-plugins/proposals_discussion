module ProposalsDiscussionPlugin::ProposalHelper

  def proposal_score(proposal)
    return '' unless proposal.published?
    normalized_score = proposal.normalized_score
    pos = 26 * (normalized_score*4 - 1).round
    content_tag 'span', '&nbsp;', :title => "#{normalized_score}", :style => "background-position-y: -#{pos}px"
  end

  def proposal_locations(proposal)
    proposal.locations.map do |location|
      content_tag 'span', location.name, :class => "location"
    end.join(', ')
  end

  def proposal_tags(proposal)
    proposal.tags.map { |t| link_to(t, :controller => 'profile', :profile => proposal.profile.identifier, :action => 'tags', :id => t.name ) }.join("\n")
  end

end
