require 'test_helper'
require 'net/ftp'

class TestUploadInvoicesFtp < ActiveSupport::TestCase

  def setup
    @ftp = MiniTest::Mock.new

    Invoice.delete_all

  end

  def test_is_directory
    assert FtpInterface.is_directory? "drwxr-xr-x    2 kry     brh       4096 2010-08-09 14:43 vcs-128135781096"
    assert_nil FtpInterface.is_directory? "-rwxr-xr-x    2 kry     brh       4096 2010-08-09 14:43 vcs-128135781096"
  end

  def test_name
    assert_equal "Melexis Ieper", FtpInterface.file_name("drwx------    2 59998    100          8192 Aug 09 15:07 Melexis Ieper")
    assert_equal "123456.pdf", FtpInterface.file_name("-rwx------    2 59998    100          8192 Aug 09 15:07 123456.pdf")
    assert_equal "vcs-128135781096", FtpInterface.file_name("drwx------    2 59998    100          8192 Aug 09 15:07 vcs-128135781096")
  end

  def test_empty_list_all_files
    @ftp.expect(:list,[],['.'])
    files = FtpInterface.list_all_files @ftp
    assert_equal [], files
  end

  def test_list_all_files
    expect_ftp_files
    files = FtpInterface.list_all_files @ftp
    assert_equal ["./Melexis Ieper/melexis1.pdf", "./Melexis Tessenderlo/melexis2.pdf"], files
  end

  def test_excluded_dir
    assert FtpInterface.directory_excluded? "drwx------    2 59998    100          8192 Aug 09 15:07 logs"
    assert FtpInterface.directory_excluded? "drwx------    2 59998    100          8192 Aug 09 15:07 new"
    assert_equal false, FtpInterface.directory_excluded?("drwx------    2 59998    100          8192 Aug 09 15:07 not_excluded")
  end

  def test_move_invoice_to_archive
    file = "melexis1.pdf"
    renamed = "archive/Melexis\ Ieper/#{Date::today.strftime("%Y%m%d")}_melexis1.pdf"
    puts "Expecting : #{[file, renamed]}"
    @ftp.expect(:rename,[],[file, renamed])
    #if directory does not yet exist:
    #@ftp.expects(:mkdir).with("/archive/Melexis\ Ieper").returns([])
    #@ftp.expects(:rename).with(file, renamed).returns([])
    FtpInterface.move_invoice_to_archive(@ftp, file, "Melexis\ Ieper")
  end

  def test_create_invoice_new
    file = "Test/new.pdf";
    new_invoice = FtpInterface.create_invoice(file);
    invoices = Invoice.all
    assert_equal(1,invoices.count, "Expected a new invoice to be created")
    assert_equal 'new', new_invoice.book_number[-3..-1], "expected new booking number"
    assert_equal 'Test', new_invoice.organization.name, "expected invoice to be added to Test organization"

  end

  def test_create_invoice_existing
    file = "Test/12345.pdf";
    # upload once
    new_invoice = FtpInterface.create_invoice(file);
    # upload second time to sim uploading existing invoice
    existing_invoice = FtpInterface.create_invoice(file);

    assert_equal nil, existing_invoice, "Existing invoice should return nil when creating"
    invoices = Invoice.all
    assert_equal(1,invoices.count, "Expected a no new invoice to be created for an existing invoice")

  end

  def expect_ftp_files
    @ftp.expect(:list,
                ["drwx------    2 59998    100          8192 Aug 09 15:07 Melexis Ieper",
                 "drwx------    2 59998    100          8192 Aug 09 15:07 logs",
                 "drwx------    2 59998    100          8192 Aug 09 15:07 Melexis Tessenderlo"],
                ['.'])
    @ftp.expect(:list,
                ["-rwx------    2 59998    100          8192 Aug 09 15:07 melexis1.pdf"],
                ['./Melexis Ieper'])
    @ftp.expect(:list,
                ["-rwx------    2 59998    100          8192 Aug 09 15:07 melexis2.pdf"],
                ['./Melexis Tessenderlo'])
  end
end
