class CreateTasksCategories < ActiveRecord::Migration
  def up
    create_table :proposals_discussion_plugin_task_categories, id: false do |t|
      t.belongs_to :task, index: { name: 'proposals_discussion_plugin_tc_task_index' }
      t.belongs_to :category, index: { name: 'proposals_discussion_plugin_tc_cat_index' }
    end
  end

  def down
    drop_table :proposals_discussion_plugin_task_categories
  end
end
