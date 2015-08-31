class CreateRankingItemTable < ActiveRecord::Migration

  def self.up
    create_table :proposals_discussion_plugin_ranking_items do |t|
      t.integer :position
      t.string  :abstract
      t.integer :votes_for
      t.integer :votes_against
      t.integer :hits
      t.decimal :effective_support
      t.integer :proposal_id
      t.timestamps
    end
    add_index(
        :proposals_discussion_plugin_ranking_items,
        [:proposal_id],
        name: 'index_proposals_discussion_plugin_ranking_proposal_id'
    )
  end

  def self.down
    drop_table :proposals_discussion_plugin_ranking_items
  end

end
