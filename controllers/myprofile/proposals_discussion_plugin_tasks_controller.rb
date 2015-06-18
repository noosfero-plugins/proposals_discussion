class ProposalsDiscussionPluginTasksController < TasksController

  def index
    @email_templates = profile.email_templates.find_all_by_template_type(:task_rejection)

    @filter_type = params[:filter_type].presence
    @filter_text = params[:filter_text].presence
    @filter_responsible = params[:filter_responsible]
    @filter_tags = params[:filter_tags]

    @view_only = !current_person.has_permission?(:perform_task, profile)

    @task_tags = [OpenStruct.new(:name => _('All'), :id => nil) ] + Task.all_tags
    @task_types = Task.pending_types_for(profile)

    if @view_only
      @tasks = Task.pending_all(profile, false, false).order_by('created_at', 'asc')
      @tasks = @tasks.where(:responsible_id => current_person.id)
    else

      @tasks =  ProposalsDiscussionPlugin::ProposalTask.pending_evaluated(profile, @filter_type, @filter_text).order_by('created_at', 'asc')
      @tasks = @tasks.where(:responsible_id => @filter_responsible.to_i != -1 ? @filter_responsible : nil) if @filter_responsible.present?
      @tasks = @tasks.tagged_with(@filter_tags, any: true) if @filter_tags.present?
    end

    @tasks = @tasks.paginate(:per_page => Task.per_page, :page => params[:page])

    @failed = params ? params[:failed] : {}

    @responsible_candidates = profile.members.by_role(profile.roles.reject {|r| !r.has_permission?('perform_task')}) if profile.organization?


  end

end
