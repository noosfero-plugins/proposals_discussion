module Noosfero
  module API
    module Entities

      class ArticleBase < Entity
        expose :ranking_position do |article, options|
          article.kind_of?(ProposalsDiscussionPlugin::Proposal) && article.ranking_item.present? ? article.ranking_item.position : nil
        end
      end

    end
  end
end
