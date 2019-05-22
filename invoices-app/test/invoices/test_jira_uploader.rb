
require 'test_helper'

class TestJiraUploader < ActiveSupport::TestCase

  def setup
    @mockjira = MiniTest::Mock.new

    @jira_uploader = JiraUploader.new(@mockjira)

    @melexis = Organization.create!(name: 'Melexis NV', default_approver: 'tbb')
  end

  def teardown
    @mockjira.verify
  end

  def test_jira_uploader
    invoice = Invoice.new(organization: @melexis,
                          book_number: 'abc123',
                          uploaded: false)
    @mockjira.expect(:create_issue, nil, [invoice])
    @jira_uploader.upload_invoice(invoice)

    puts invoice
    assert_equal 1, invoice.uploaded
    assert_equal "Success", invoice.result
  end

end
