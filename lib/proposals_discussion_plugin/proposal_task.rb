class ProposalsDiscussionPlugin::ProposalTask < Task

  validates_presence_of :requestor_id, :target_id
  validates_associated :article_object

  settings_items :name, :type => String
  settings_items :ip_address, :type => String
  settings_items :user_agent, :type => String
  settings_items :referrer, :type => String
  settings_items :article, :type => Hash, :default => {}
  settings_items :closing_statment, :article_parent_id


  scope :pending_evaluated, lambda { |profile, filter_type, filter_text|
    self
      .to(profile)
      .without_spam.pending
      .of(filter_type)
      .like('data', filter_text)
      .where(:status => ProposalsDiscussionPlugin::ProposalTask::Status.evaluated_statuses)
  }

  before_create do |task|
    if !task.target.nil?
      organization = task.target
      responsible_candidates = organization.members.by_role(organization.roles.reject {|r| !r.has_permission?('perform_task')})
      task.responsible = responsible_candidates.sample
    end
  end

  def unflagged?
    ! flagged?
  end

  def flagged?
    flagged_for_approval? || flagged_for_reproval?
  end

  def flagged_for_approval?
    Status::FLAGGED_FOR_APPROVAL.eql?(self.status)
  end

  def flagged_for_reproval?
    Status::FLAGGED_FOR_REPROVAL.eql?(self.status)
  end

  after_create :schedule_spam_checking

  module Status
    FLAGGED_FOR_APPROVAL = 5
    FLAGGED_FOR_REPROVAL = 6

    class << self
      def names
        [
          nil,
          N_('Active'), N_('Cancelled'), N_('Finished'),
          N_('Hidden'), N_('Flagged for Approval'), N_('Flagged for Reproval')
        ]
      end

      def evaluated_statuses
        [
          FLAGGED_FOR_APPROVAL,
          FLAGGED_FOR_REPROVAL
        ]
      end
    end
  end


  def flag_accept_proposal(evaluated_by)
    transaction do
      if evaluated_by
        ProposalsDiscussionPlugin::ProposalEvaluation.new do |evaluation|
          evaluation.evaluated_by = evaluated_by
          evaluation.flagged_status = Status::FLAGGED_FOR_APPROVAL
          evaluation.proposal_task = self
          evaluation.save!
        end
      end
      self.status = Status::FLAGGED_FOR_APPROVAL
      self.save!
      return true
    end
  end

  def flag_reject_proposal(evaluated_by)
    transaction do
      if evaluated_by
        ProposalsDiscussionPlugin::ProposalEvaluation.new do |evaluation|
          evaluation.evaluated_by = evaluated_by
          evaluation.flagged_status = Status::FLAGGED_FOR_REPROVAL
          evaluation.proposal_task = self
          evaluation.save!
        end
      end
      self.status = Status::FLAGGED_FOR_REPROVAL
      self.save!
      return true
    end
  end


  def schedule_spam_checking
    self.delay.check_for_spam
  end

  def sender
    requestor.name if requestor
  end

  def article_parent
    Article.find_by_id article_parent_id.to_i
  end

  def article_object
    if @article_object.nil?
      @article_object = article_type.new(article.merge(target.present? ? {:profile => target} : {}).except(:type))
      @article_object.parent = article_parent
      @article_object.author = requestor if requestor.present?
    end
    @article_object
  end

  def article_type
    if article[:type].present?
      type = article[:type].constantize
      return type if type < Article
    end
    TinyMceArticle
  end

  def perform
    article_object.save!
  end

  def title
    _("New proposal")
  end

  def article_abstract
    article[:abstract]
  end

  def abstract
    article_abstract
  end

  def information
    {:message => _("%{requestor} wants to send the following proposal. <br/>%{abstract}"), :variables => {:abstract => abstract}}
  end

  def icon
    {:type => :profile_image, :profile => requestor, :url => requestor.url}
  end

#  def permission
#    :#manage_memberships
#  end

  def target_notification_description
    _('%{requestor} wants to send a proposal.') % {:requestor => requestor.name}
  end

  def target_notification_message
    target_notification_description + "\n\n" +
    _('You will need login to %{system} in order to accept or reject the proposal sent by %{requestor}') % { :system => target.environment.name, :requestor => requestor.name}
  end

#  def article_title
#    article ? article.title : _('(The original text was removed)')
#  end

#  def article
#    Article.find_by_id data[:article_id]
#  end

#  def article= value
#    data[:article_id] = value.id
#  end

#  def name
#    data[:name].blank? ? (article ? article.name : _("Article removed.")) : data[:name]
#  end
#
#  def name= value
#    data[:name] = value
#  end

#  def article_parent
#    Article.find_by_id article_parent_id.to_i
#  end
#
#  def article_parent= value
#    self.article_parent_id = value.id
#  end
#
#  def abstract= value
#    data[:abstract] = value
#  end
#
#  def abstract
#    data[:abstract].blank? ? (article ? article.abstract : '') : data[:abstract]
#  end
#
#  def body= value
#    data[:body] = value
#  end
#
#  def body
#    data[:body].blank? ? (article ? article.body : "") : data[:body]
#  end
#
#  def icon
#    result = {:type => :defined_image, :src => '/images/icons-app/article-minor.png', :name => name}
#    result.merge({:url => article.url}) if article
#    return result
#  end

#  def linked_subject
#raise article.inspect
#    {:text => name, :url => article.url} if article
#  end

  def accept_details
    true
  end

  def reject_details
    true
  end

  def default_decision
    if article
      'skip'
    else
      'reject'
    end
  end

  def accept_disabled?
    article.blank?
  end

  def task_finished_message
    if !closing_statment.blank?
      _("Your request for publishing the proposal \"%{article}\" was approved. Here is the comment left by the admin who approved your proposal:\n\n%{comment} ") % {:article => name, :comment => closing_statment}
    else
      _('Your request for publishing the proposal "%{article}" was approved.') % {:article => name}
    end
  end

  def task_cancelled_message
    message = _('Your request for publishing the proposal "%{article}" was rejected.') % {:article => name}
    if !reject_explanation.blank?
      message += " " + _("Here is the reject explanation left by the moderator who rejected your proposal: \n\n%{reject_explanation}") % {:reject_explanation => reject_explanation}
    end
    message
  end

  def after_spam!
    SpammerLogger.log(ip_address, self)
    self.delay.marked_as_spam
  end

  def after_ham!
    self.delay.marked_as_ham
  end
end
