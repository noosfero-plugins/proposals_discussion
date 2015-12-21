class AddCategoriesProposal < ActiveRecord::Migration

  def self.up
    ProposalsDiscussionPlugin::Proposal.find_each do |proposal|
      proposal.inherit_parent_categories
    end
  end

  def self.down
    puts "Warning: cannot restore original categories"
  end

end
