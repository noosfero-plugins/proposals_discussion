module CmsHelper

  def link_to_article(article)
    article_name = article.title
    if article.folder?
      link_to article_name, {:action => 'view', :id => article.id}, :class => icon_for_article(article)
    else
      if article.image?
        image_tag(icon_for_article(article)) + link_to(article_name, article.url)
      else
        if "ProposalsDiscussionPlugin::Proposal".eql? article.type
          link_to article.abstract, article.url, :class => icon_for_article(article)
        else
          link_to article_name, article.url, :class => icon_for_article(article)
        end
      end
    end
  end
end
