class AddArticleRefToTasks < ActiveRecord::Migration

  def up
    add_reference :tasks, :article, index: true, foreign_key: true, on_delete: :nullify
    ProposalsDiscussionPlugin::ProposalTask.find_each do |task|

      if task.data[:article]
        field = {name: task.data[:article][:name]}
        if task.data[:article][:id]
          field = {id: task.data[:article][:id]}
        end
        article = Article.find_by field

        if article.nil?
          data = task.data[:article].merge({profile: task.target}).except(:type)
          article = Article.create!(data)
        end
        task.update_column(:article_id, article.id)
      end

    end
  end

  def down
    remove_reference :tasks, :article, index: true, foreign_key: true
  end

end
