require File.dirname(__FILE__) + '/../test_helper'

class ProposalTest < ActiveSupport::TestCase

  def setup
    @profile = fast_create(Community)
    @person = fast_create(Person)
    @proposal = ProposalsDiscussionPlugin::Proposal.new(:name => 'test', :profile => @profile)
    @proposal.created_by = @person
  end

  attr_reader :profile, :proposal, :person

  should 'save a proposal' do
    proposal.abstract = 'abstract'
    assert proposal.save
  end

  should 'do not save a proposal without abstract' do
    proposal.save
    assert proposal.errors['abstract'].present?
  end

  should 'allow edition if user is the author' do
    assert proposal.allow_edit?(person)
  end

  should 'do not allow edition if user is not the author' do
    assert !proposal.allow_edit?(fast_create(Person))
  end

end
