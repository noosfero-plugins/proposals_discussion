require File.join(Rails.root,'lib','noosfero','api','entities')
module Noosfero
  module API
    module Entities

      class Article < ArticleBase
#FIXME Leandro changed the method to model
#        expose :ranking_position do |article, options|
#          article.kind_of?(ProposalsDiscussionPlugin::Proposal) && article.ranking_item.present? ? article.ranking_item.position : nil
#        end
        expose :ranking_position
        #FIXME see why children counter cache is not working
        expose :amount_of_children do |article, options|
          article.children.count
        end
      end

      class RankingItem < Entity
        root :proposals, :proposal
        expose :id, :position, :abstract, :body, :votes_for, :votes_against
        expose :hits, :effective_support, :proposal_id, :created_at
        expose :updated_at, :slug, :categories
      end

    end
  end

end
