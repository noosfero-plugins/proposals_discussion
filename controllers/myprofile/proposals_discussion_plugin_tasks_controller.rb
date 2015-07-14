class ProposalsDiscussionPluginTasksController < TasksController

  protect [:perform_task, :view_tasks], :profile, :only => [:index, :save_tags, :search_tags, :save_categories]
  protect :perform_task, :profile, :except => [:index, :save_tags, :search_tags, :save_categories]

  def index
    @rejection_email_templates = profile.email_templates.find_all_by_template_type(:task_rejection)
    @acceptance_email_templates = profile.email_templates.find_all_by_template_type(:task_acceptance)

    @filter_type = params[:filter_type].presence
    @filter_text = params[:filter_text].presence
    @filter_responsible = params[:filter_responsible]
    @filter_categories = params[:filter_categories]

    @filter_status = params[:filter_status]

    @view_only = !current_person.has_permission?(:perform_task, profile) || params[:view_only]

    @task_categories = [OpenStruct.new(:name => _('All'), :id => nil) ] + ProposalsDiscussionPlugin::TaskCategory.all
    @task_types = Task.pending_types_for(profile)

    # maps statuses which would be used in status filter
    @task_statuses = ProposalsDiscussionPlugin::ProposalTask::Status.names.each_with_index.map { |x,i| OpenStruct.new(:id => i, :name =>x) }
    @task_statuses.reject! {|status| [2,3,4].include? status.id}

    # filter for evaluator profile
    if @view_only
      @tasks = ProposalsDiscussionPlugin::ProposalTask.pending_all(profile, false, false).order_by('created_at', 'asc')
      @tasks = @tasks.where(:responsible_id => current_person.id)
    else
      # filter for moderator
      if @filter_status.present? && ! "0".eql?(@filter_status) && !["2","3","4"].include?(@filter_status)
        @tasks = ProposalsDiscussionPlugin::ProposalTask.filter_by_status(profile, @filter_type, @filter_text, @filter_status ).order_by('created_at', 'asc')
      else
        @tasks =  ProposalsDiscussionPlugin::ProposalTask.pending_evaluated(profile, @filter_type, @filter_text).order_by('created_at', 'asc')
      end

      @tasks = @tasks.where(:responsible_id => @filter_responsible.to_i != -1 ? @filter_responsible : nil) if @filter_responsible.present?

    end

    @tasks = @tasks.paginate(:per_page => Task.per_page, :page => params[:page])

    @failed = params ? params[:failed] : {}

    @responsible_candidates = profile.members.by_role(profile.roles.reject {|r| !r.has_permission?('perform_task')}) if profile.organization?
  end

  def save_categories

    result = {
      success: false,
      message: _('Error to save categories. Please, contact the system admin')
    }

    if request.post? && params[:tag_list]

      categories_list = params[:tag_list].split(',')
      task = Task.to(profile).find_by_id params[:task_id]

      categories_data = []
      categories_list.each do |category_name|
        category = ProposalsDiscussionPlugin::TaskCategory.find_by_name(category_name)
        categories_data << category
      end
      task.categories = categories_data
      save = task.save!

      if save
        result = {
          success: true,
          message: _('Saved with success!')
        }
      end
    end

    render json: result

  end

end
