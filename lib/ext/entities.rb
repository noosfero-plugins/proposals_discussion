module Noosfero
  module API
    module Entities

      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        class ArticleBase < Entity
          expose :ranking_position do |article, options|
            article.kind_of?(ProposalsDiscussionPlugin::Proposal) && article.ranking_item.present? ? article.ranking_item.position : nil
          end
        end
      end

    end
  end

end
