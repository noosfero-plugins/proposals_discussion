class ProposalsDiscussionPlugin::TaskCategory < Category

  has_and_belongs_to_many :tasks, join_table: :proposals_discussion_plugin_task_categories, foreign_key: :category_id
end
