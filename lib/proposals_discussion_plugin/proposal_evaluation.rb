class ProposalsDiscussionPlugin::ProposalEvaluation <  ActiveRecord::Base
  belongs_to :proposal_task
  belongs_to :evaluated_by, :class_name => 'Person', :foreign_key => :evaluator_id

  attr_accessor :flagged_status

end
