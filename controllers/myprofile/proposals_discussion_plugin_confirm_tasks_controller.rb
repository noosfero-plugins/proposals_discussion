class ProposalsDiscussionPluginConfirmTasksController < MyProfileController
  protect :perform_task, :profile, :only => [:approve_proposal, :reprove_proposal]

  def approve_proposal
    result = {}
    if request.post?
      result = process_decision(params, :finish)
    end
    render json: result
  end

  def reprove_proposal
    result = {}
    if request.post?
      result = process_decision(params, :cancel)
    end
    render json: result
  end

private

  def process_decision(params, decision)
    result = {
      success: false,
      message: _('Error flagging proposal. Please, contact the system admin')
    }
    if params[:task_id] and request.post?
      begin
        task = profile.find_in_all_tasks(params[:task_id])
        task.tag_list = params[:tag_list]
        task.article_parent_id = params[:article_parent_id] if decision.to_s == 'finish'
        task.email_template_id = params[:email_template_id]
        task.send(decision, current_person)
        result = {:success =>  true }
      rescue Exception => ex
        message = "#{task.title} (#{task.requestor ? task.requestor.name : task.author_name})" if task
        message = "#{message} #{ex.message}"
        result[:message] += ". #{message}"
      end
      return result
    end
  end
end
