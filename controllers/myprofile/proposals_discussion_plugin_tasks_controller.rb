class ProposalsDiscussionPluginTasksController < TasksController

  def index
    @email_templates = profile.email_templates.find_all_by_template_type(:task_rejection)

    @filter_type = params[:filter_type].presence
    @filter_text = params[:filter_text].presence
    @filter_responsible = params[:filter_responsible]
    @filter_tags = params[:filter_tags]

    @filter_status = params[:filter_status]

    @view_only = !current_person.has_permission?(:perform_task, profile) || params[:view_only]

    @task_tags = [OpenStruct.new(:name => _('All'), :id => nil) ] + Task.all_tags
    @task_types = Task.pending_types_for(profile)

    # maps statuses which would be used in status filter
    @task_statuses = ProposalsDiscussionPlugin::ProposalTask::Status.names.each_with_index.map { |x,i| OpenStruct.new(:id => i, :name =>x) }
    @task_statuses.reject! {|status| [2,3,4].include? status.id}

    # filter for evaluator profile
    if @view_only
      @tasks = Task.pending_all(profile, false, false).order_by('created_at', 'asc')
      @tasks = @tasks.where(:responsible_id => current_person.id)
    else
      # filter for moderator
      if @filter_status.present? && ! "0".eql?(@filter_status) && !["2","3","4"].include?(@filter_status)
        @tasks = ProposalsDiscussionPlugin::ProposalTask.filter_by_status(profile, @filter_type, @filter_text, @filter_status ).order_by('created_at', 'asc')
      else
        @tasks =  ProposalsDiscussionPlugin::ProposalTask.pending_evaluated(profile, @filter_type, @filter_text).order_by('created_at', 'asc')
      end

      @tasks = @tasks.where(:responsible_id => @filter_responsible.to_i != -1 ? @filter_responsible : nil) if @filter_responsible.present?

      @tasks = @tasks.tagged_with(@filter_tags, any: true) if @filter_tags.present?

    end

    @tasks = @tasks.paginate(:per_page => Task.per_page, :page => params[:page])

    @failed = params ? params[:failed] : {}

    @responsible_candidates = profile.members.by_role(profile.roles.reject {|r| !r.has_permission?('perform_task')}) if profile.organization?
  end

end
