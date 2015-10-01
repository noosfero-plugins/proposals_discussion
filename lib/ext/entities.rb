require File.join(Rails.root,'lib','noosfero','api','entities')
module Noosfero
  module API
    module Entities

      #FIXME make test
      class Person < Profile
        expose :ranking_position
      end

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
