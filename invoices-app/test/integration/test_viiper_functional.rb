require 'test_helper'
require 'fileutils'
require 'securerandom'

class TestViiperFunctional < ActiveSupport::TestCase

  def setup
    Invoice.destroy_all
    Organization.destroy_all
    @organization = Organization.create!(name: 'Melexis Ieper',
                                         default_approver: 'tbb',
                                         backends: ['viiper'],
                                         viiper_dir_name: 'INVOICE_SCANS_IEP')

    book_number = SecureRandom.uuid
    @test_filename = "sample/#{book_number}.pdf"
    FileUtils.cp('sample/12345678.pdf',@test_filename)
    @invoice = Invoice.create!(organization: @organization,
                               book_number: book_number,
                               file_name: @test_filename,
                               uploaded: false)

    @viiper_uploader = ViiperUploader.new({})
  end


  def teardown
    @invoice.destroy
    @organization.destroy
    @viiper_uploader.close
    FileUtils.rm @test_filename
  end

  def test_max_id_functional
    id = @viiper_uploader.max_apex_import_id()
    assert id > 0
  end


  def test_upload_invoice_functional
    max_id = @viiper_uploader.max_apex_import_id()
    @viiper_uploader.upload_invoice(@invoice)
    file_id = @viiper_uploader.invoice_apex_id(@invoice)
    assert_equal 1, @invoice.uploaded
    assert file_id >= max_id, "Expected an uploaded file with a new id."

    # test double upload is blocked
    @invoice.uploaded = 0
    @viiper_uploader.upload_invoice(@invoice)
    file_id2 = @viiper_uploader.invoice_apex_id(@invoice)
    assert_equal file_id, file_id2, "Expected the same file id as the first upload"
    assert_equal 1, @invoice.uploaded

  end

  def test_failed_upload_invoice_functional
    @invoice.file_name = 'sample/bad_data.junk'
    max_id = @viiper_uploader.max_apex_import_id()
    @viiper_uploader.upload_invoice(@invoice)
    file_id = @viiper_uploader.invoice_apex_id(@invoice)
    assert_equal 0, @invoice.uploaded
    assert_match /^ORA-20001:.*We import only PDF.*/, @invoice.result

  end

  def test_path_for_directory
    path = @viiper_uploader.path_for_directory(@invoice)
    assert_equal '/var/lib/viiper/invoice_scans/IEP', path
  end

  def test_all_dir_names
    dir_names = @viiper_uploader.all_dir_names
    assert_includes(dir_names, 'INVOICE_SCANS_ARCHIVE')
    assert_includes(dir_names, 'INVOICE_SCANS_IEP')
    assert_includes(dir_names, 'INVOICE_SCANS_CON')
  end
end
