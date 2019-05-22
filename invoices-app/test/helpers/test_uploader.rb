require 'minitest/autorun'
require 'minitest/mock'
require 'uploader'
require 'test_helper'


class TestUploader < ActiveSupport::TestCase

  def setup
    @mockjira = MiniTest::Mock.new
    @mockviiper = MiniTest::Mock.new
    @uploader = Uploader.new(jira: @mockjira, viiper: @mockviiper)

    Invoice.delete_all

    Organization.delete_all
    Organization.create!(name:'Elex', backends:['jira'])
    Organization.create!(name:'Melexis Ieper', backends:['viiper'])
  end

  def teardown
    @mockjira.verify
    @mockviiper.verify
  end

  def test_jira_invoice
    invoice = Invoice.create!(organization: 'Elex',
                    book_number: 'abc123',
                    uploaded: false
                             )
    puts "Invoices: #{Invoice.all.count}"
    @mockjira.expect(:upload_invoice, nil, [invoice])
    @uploader.upload_invoices()
  end

  def test_viiper_invoice
    Invoice.create!(organization: 'Melexis Ieper',
                    book_number: 'abc123',
                    uploaded: false
                   )
    @mockviiper.expect(:upload_invoice, nil, [Invoice])
    @uploader.upload_invoices()
  end


    def test_mixed_invoice
    Invoice.create!(organization: 'Elex',
                    book_number: 'abc123',
                    uploaded: false
                   )
    Invoice.create!(organization: 'Melexis Ieper',
                    book_number: 'abc123',
                    uploaded: false
                   )
    @mockjira.expect(:upload_invoice, nil, [Invoice])
    @mockviiper.expect(:upload_invoice, nil, [Invoice])
    @uploader.upload_invoices()
  end

end
