class AddProposalDiscussionPluginSimplifiedAbstractToTasks < ActiveRecord::Migration
  def change
    add_column :tasks, :proposal_discussion_plugin_simplified_abstract, :text
    add_index :tasks, :proposal_discussion_plugin_simplified_abstract
    ProposalsDiscussionPlugin::ProposalTask.find_each do |t|
      t.update_attribute :proposal_discussion_plugin_simplified_abstract, ProposalsDiscussionPlugin::ProposalTask.simplify(t.abstract)
    end
  end
end
