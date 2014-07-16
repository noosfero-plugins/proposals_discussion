require File.dirname(__FILE__) + '/../test_helper'

class ProposalsDiscussionPluginTest < ActiveSupport::TestCase

  def setup
    @profile = fast_create(Community)
    @proposal = ProposalsDiscussionPlugin::Proposal.new(:name => 'test', :profile => @profile)
  end

  attr_reader :profile, :proposal

  should 'save a proposal' do
    proposal.abstract = 'abstract'
    assert proposal.save
  end

  should 'do not save a proposal without abstract' do
    proposal.save
    assert proposal.errors['abstract'].present?
  end

end
