class ProposalsDiscussionPluginEvaluateTasksController < MyProfileController

  protect :view_tasks, :profile, :only => [:flag_approve_proposal, :flag_reject_proposal]

  def flag_approve_proposal
    if request.post? && params[:task_id]
      result = {
        success: false,
        message: _('Error flagging proposal. Please, contact the system admin')
      }

      task = Task.to(profile).find_by_id params[:task_id]
      save = task.flag_accept_proposal(current_person)

      if save
        result = {:success =>  true }
      end
    end

    render json: result
  end

  def flag_reject_proposal
    if request.post? && params[:task_id]
      result = {
        success: false,
        message: _('Error flagging proposal. Please, contact the system admin')
      }

      task = Task.to(profile).find_by_id params[:task_id]
      save = task.flag_reject_proposal(current_person)

      if save
        result = {:success =>  true }
      end
    end

    render json: result
  end

end
