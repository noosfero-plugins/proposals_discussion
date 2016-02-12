require_dependency 'article'

class Article

  has_one :task

  def ranking_position
    self.kind_of?(ProposalsDiscussionPlugin::Proposal) && self.ranking_item.present? ? self.ranking_item.position : nil
  end

end
