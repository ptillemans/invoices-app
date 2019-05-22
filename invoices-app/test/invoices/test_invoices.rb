require 'test_helper'

class TestInvoices < ActiveSupport::TestCase

  def setup
    Invoice.delete_all

    @test_org = Organization.create!(name: "Test")

    inv = Invoice.new()
    inv.organization = @test_org
    inv.book_number = "12345"
    inv.approver = "xyz"
    inv.file_name = "dummy"
    inv.uploaded = true
    inv.jira_id = "INVAPP-007"
    inv.jira_status = 3
    inv.save

    inv = Invoice.new()
    inv.organization = @test_org
    inv.book_number = "12346"
    inv.approver = "xyz"
    inv.file_name = "dummy"
    inv.uploaded = 0
    inv.jira_id = "INVAPP-007"
    inv.jira_status = 3
    inv.save
  end

  def test_db
    invoices = Invoice.all;
    assert_equal(2, invoices.length);
    assert_equal("12345", invoices[0].book_number);
    assert_equal("12346", invoices[1].book_number);
  end

  def test_new_invoices
    invoices = Invoice.new_invoices
    assert_equal(1, invoices.length);
    assert_equal("12346", invoices[0].book_number);
  end

  def test_invoice_summary
    invoices = Invoice.new_invoices
    assert_match /Invoice\(.*\): 12346 for xyz in Test --> dummy \(uploaded : 0\)/,
                 invoices[0].to_s

  end
end
