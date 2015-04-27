require_dependency 'environment'

class Environment

  #FIXME make this test
  has_many :discussions, :through => :profiles, :source => :articles, :class_name => ProposalsDiscussionPlugin::Discussion


end
