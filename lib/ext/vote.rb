require_dependency 'models/vote'

class Vote

  validate :proposals_discussion_plugin_modify_vote
  before_destroy :proposals_discussion_plugin_modify_vote

  def proposals_discussion_plugin_modify_vote
    if voteable.kind_of?(ProposalsDiscussionPlugin::Proposal) && !voteable.allow_vote?
      errors.add(:base, _("Can't vote in this discussion anymore."))
      false
    end
  end

end
