require 'test_helper'

class Test_invoices_onea < ActiveSupport::TestCase

  def getDate
    return Date::today.strftime("%Y%m%d")
  end

  def test_create_invoice
    tmpfile = create_tmpfile("melexis", "123.pdf")
    inv = FtpInterface.create_invoice(tmpfile)

    assert_equal("melexis", inv.organization.name)
    assert_equal(getDate + "_123", inv.book_number)
    assert_equal(Dir.tmpdir + "/melexis/123.pdf", inv.file_name)
    File::delete(tmpfile)
  end

  def test_create_uppercase_invoice
    tmpfile = create_tmpfile("melexis", "TEXT INVOICE")
    inv = FtpInterface.create_invoice(tmpfile)

    assert_equal(getDate + "_text invoice", inv.book_number)

    File::delete(tmpfile)
  end

  def test_invoice_summary
    tmpfile = create_tmpfile("melexis", "123.pdf")
    inv = FtpInterface.create_invoice(tmpfile)

    assert_equal("Invoice " + getDate + "_123 for melexis (uploaded: 0)", inv.to_s)
  end

  def create_tmpfile(path, filename)
    directory = Dir.tmpdir + "/" + path
    if !File.exist?(directory) then
      p = Pathname.new(directory)
      p.mkdir()
    end
    tmpfile = File.join(Dir.tmpdir, path, filename)
    File.new(tmpfile, "w")
    return tmpfile
  end
end
