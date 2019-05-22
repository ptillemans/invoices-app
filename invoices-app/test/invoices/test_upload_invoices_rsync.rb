require 'test_helper'
require 'fileutils'

class TestUploadInvoicesRsync < ActiveSupport::TestCase

  def setup
    @source = '/tmp/invoices_test/source/'
    @target = '/tmp/invoices_test/target/'
    FileUtils.mkdir_p @source
    FileUtils.mkdir_p @target

    elex_dir = "#{@source}/#{organizations(:elex).name}"
    FileUtils.mkdir_p elex_dir
    FileUtils.copy 'sample/12345678.pdf', elex_dir

  end

  def teardown
    # hardcoded to avoid mistakes
    #FileUtils.rm_r '/tmp/invoices_test'
  end


  def test_upload_invoices
    RsyncInterface.update_database(@source, @target)
    inv = Invoice.where(book_number: '12345678', organization: organizations(:elex)).first
    assert_not_nil inv
  end
end
