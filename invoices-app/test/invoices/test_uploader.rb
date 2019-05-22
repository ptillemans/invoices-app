require 'test_helper'


class TestUploader < ActiveSupport::TestCase

  def setup

    @mockjira = MiniTest::Mock.new
    @mockviiper = MiniTest::Mock.new
    @uploader = Uploader.new(jira: @mockjira, viiper: @mockviiper)

    Invoice.delete_all

    Organization.delete_all
    @elex = Organization.create!(name:'Elex', backends:['jira'])
    @melexis_ieper = Organization.create!(name:'Melexis Ieper', backends:['viiper'])
    @melexis = Organization.create!(name:'Melexis', backends:['jira', 'viiper'])

  end

  def teardown
    @mockjira.verify
    @mockviiper.verify
  end

  def test_jira_invoice
    invoice = Invoice.create!(organization: @elex,
                    book_number: 'abc123',
                    uploaded: 0
                             )
    @mockjira.expect(:upload_invoice, nil, [invoice])
    @uploader.upload_invoices()
  end

  def test_viiper_invoice
    Invoice.create!(organization: @melexis_ieper,
                    book_number: 'abc123',
                    uploaded: 0
                   )
    @mockviiper.expect(:upload_invoice, nil, [Invoice])
    @uploader.upload_invoices()
  end


  def test_mixed_invoice
    Invoice.create!(organization: @elex,
                    book_number: 'abc123',
                    uploaded: 0
                   )
    Invoice.create!(organization: @melexis_ieper,
                    book_number: 'abc123',
                    uploaded: 0
                   )
    @mockjira.expect(:upload_invoice, nil, [Invoice])
    @mockviiper.expect(:upload_invoice, nil, [Invoice])
    @uploader.upload_invoices()
  end

  def test_both_invoics
    Invoice.create!(organization: @melexis,
                    book_number: 'abc123',
                    uploaded: 0
                   )
    @mockjira.expect(:upload_invoice, nil, [Invoice])
    @mockviiper.expect(:upload_invoice, nil, [Invoice])
    @uploader.upload_invoices()
  end
end
