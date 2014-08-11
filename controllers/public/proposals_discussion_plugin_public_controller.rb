class ProposalsDiscussionPluginPublicController < ApplicationController

  needs_profile

  def load_proposals
    holder = profile.articles.find(params[:holder_id])
    page = (params[:page] || 1).to_i
    set_rand_cookie if page == 1

    set_seed
    @proposals = holder.proposals.public.reorder('random()')
    @proposals = @proposals.page(page).per_page(5)

    unless @proposals.empty?
      render :partial => 'content_viewer/proposals_list_content', :locals => {:proposals => @proposals, :holder => holder, :page => page+1}
    else
      render :text => ''
    end
  end

  private

  def set_seed
    #XXX postgresql specific
    seed_val = profile.connection.quote(cookies[:_noosfero_proposals_discussion_rand_seed])
    profile.connection.execute("select setseed(#{seed_val})")
  end

  def set_rand_cookie
    cookies[:_noosfero_proposals_discussion_rand_seed] = {value: rand, expires: Time.now + 600}
  end

end
