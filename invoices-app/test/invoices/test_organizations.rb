require 'test_helper'

class TestOrganizations < ActiveSupport::TestCase

  def setup
    Organization.delete_all
    Organization.create!(name:'Elex', default_approver:'tbb', backends: ['jira'])
    Organization.create!(name:'Melexis Ieper', default_approver:'tbb', backends: ['viiper'])
  end

  def test_db
    organizations = Organization.all;
    assert_equal(2, organizations.length)
  end

  def test_jira_organization
    organization = Organization.by_name('Elex')
    assert_equal ['jira'], organization.backends
  end

  def test_viiper_organization
    organization = Organization.by_name('Melexis Ieper')
    assert_equal ['viiper'], organization.backends
  end

  def test_enforce_unique_name
    err = assert_raises ActiveRecord::RecordInvalid do
                          Organization.create!(name: 'Elex',
                                               default_approver: 'ikke',
                                               backends: ['viiper'])
    end
    assert_match /Name has already been taken/, err.message
  end

  def test_backends_default
    org = Organization.create(name:'Test Org',default_approver:'test')
    assert_equal ['jira'], org.backends
  end
end
