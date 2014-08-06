module ProposalsDiscussionPlugin::ProposalHelper

  def visibility_options(article, tokenized_children)
    article.published = false if article.new_record?
    super
  end

end
