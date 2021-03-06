class ProposalsDiscussionPluginPublicController < ApplicationController

  needs_profile

  before_filter :check_permission

  def load_proposals
    page = (params[:page] || 1).to_i
    set_rand_cookie if page == 1
    order = params[:order]

    @proposals = order_proposals(@holder.proposals.published, order)
    @proposals = @proposals.page(page).per_page(4)

    render :partial => 'content_viewer/proposals_list_content', :locals => {:proposals => @proposals, :holder => @holder, :page => page+1, :order => order}
  end

  private

  def check_permission
    @holder = profile.articles.find(params[:holder_id])
    render_access_denied unless @holder.display_to?(user)
  end

  def order_proposals(proposals, order)
    case order
    when 'alphabetical'
      proposals.reorder('name')
    when 'recent'
      proposals.reorder('created_at DESC')
    when 'most_commented'
      proposals.reorder('comments_count DESC')
    when 'most_recently_commented'
      proposals.joins("LEFT OUTER JOIN comments ON comments.source_id=articles.id AND comments.created_at >= '#{5.days.ago}'").group('articles.id').reorder('count(comments.id) DESC')
    else
      set_seed
      proposals.reorder('random()')
    end
  end

  def set_seed
    #XXX postgresql specific
    seed_val = ActiveRecord::Base.connection.quote(cookies[:_noosfero_proposals_discussion_rand_seed])
    ActiveRecord::Base.connection.execute("select setseed(#{seed_val})")
  end

  def set_rand_cookie
    cookies[:_noosfero_proposals_discussion_rand_seed] = {value: rand, expires: Time.now + 600}
  end

end
