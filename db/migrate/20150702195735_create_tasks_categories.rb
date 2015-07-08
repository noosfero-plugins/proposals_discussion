class CreateTasksCategories < ActiveRecord::Migration
  def up
    create_table :proposals_discussion_plugin_task_categories, id: false do |t|
      t.belongs_to :task, index: true
      t.belongs_to :category, index: true

    end
  end

  def down
    drop_table :proposals_discussion_plugin_task_categories
  end
end
