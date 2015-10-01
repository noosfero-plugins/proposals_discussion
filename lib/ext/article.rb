require_dependency 'article'

class Article

  def ranking_position
    self.kind_of?(ProposalsDiscussionPlugin::Proposal) && self.ranking_item.present? ? self.ranking_item.position : nil
  end

end
