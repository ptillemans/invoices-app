require 'test_helper'

ELEX_SAMPLE_FILE="sample/elexinfo.xls"

class TestElexInfo < ActiveSupport::TestCase

  def setup
    Booking.delete_all
    @invoice_info = ElexInfoParser.get_info_from_excel_file(ELEX_SAMPLE_FILE)
  end


  def test_info
    # also detects removal of duplicates
    assert_equal(16, @invoice_info.length);
  end

  def test_rows
    line = @invoice_info[0]
    assert_equal("Demo", line.organization)
    assert_equal("20070470", line.book_number)
    assert_equal(82.64, line.amount)
    assert_equal("sva", line.reference)
    assert_equal("ABX", line.supplier)
    assert_equal("20070470", line.barcode)

    line = @invoice_info[1]
    assert_equal("Elex", line.organization)
    assert_equal("1", line.book_number)
  end

  def test_db
    # also detects removal of duplicates
    bookings = Booking.all
    assert_equal(16, bookings.length);
  end

end
