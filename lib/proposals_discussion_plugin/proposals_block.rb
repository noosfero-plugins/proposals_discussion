class ProposalsDiscussionPlugin::ProposalsBlock < Block

  def self.description
    _('Display content produced in proposals discussion.')
  end

  def self.short_description
    _('Display proposals discussions')
  end

  def self.pretty_name
    _('Proposals Discussion Block')
  end

  def default_title
    _('Proposals Discussion Block')
  end

  def help
    _('This block display proposals discussion content.')
  end

  def content(args={})
    proposals = self.proposals
    block = self
    proc do
      render :file => 'blocks/proposals_block', :locals => {:proposals => proposals, :block => block}
    end
  end

  def footer
    nil
  end

  def proposals
    ProposalsDiscussionPlugin::Discussion.find(:all)
  end

end
