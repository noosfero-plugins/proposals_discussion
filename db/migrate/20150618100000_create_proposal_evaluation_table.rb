class CreateProposalEvaluationTable < ActiveRecord::Migration
  def self.up
    create_table :proposals_discussion_plugin_proposal_evaluations do |t|
      t.integer "proposal_task_id"
      t.integer "evaluator_id"
      t.integer "flagged_status"
      t.timestamps
    end
    add_index(
        :proposals_discussion_plugin_proposal_evaluations,
        [:proposal_task_id],
        name: 'index_proposals_discussion_plugin_proposal_task_id'
    )
    add_index(
        :proposals_discussion_plugin_proposal_evaluations,
        [:evaluator_id],
        name: 'index_proposals_discussion_plugin_proposal_evaluator_id'
    )
  end
  def self.down
    drop_table :proposals_discussion_plugin_proposal_evaluations
  end
end
