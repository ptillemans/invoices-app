require 'test_helper'

class FremachBookingParserTest < ActiveSupport::TestCase
  def setup
    Booking.delete_all
    @parser = FremachBookingParser.new('MyOrganization')
  end

  def test_parser

    test_input =  <<"EOF"
"Supplier","Dagboekcode","Documentnr.","Bedrag"
"ACME","CODE",123456,-123.45 BEF
EOF

    @parser.parse_file(StringIO.new(test_input))

    booking = Booking.first
    assert_equal "ACME", booking.supplier
    assert_in_delta 123.45, booking.amount, 0.0001, "Amount is different : #{booking.amount} vs 123.45"
    assert_equal booking.book_number, "code 123456"

  end

  def test_parser_default_code

    test_input =  <<"EOF"
"Supplier","Dagboekcode","Documentnr.","Bedrag"
"ACME","AFGA",123456,-123.45 BEF
EOF

    @parser.parse_file(StringIO.new(test_input))

    booking = Booking.first
    assert_equal "ACME", booking.supplier
    assert_in_delta 123.45, booking.amount, 0.0001, "Amount is different : #{booking.amount} vs 123.45"
    assert_equal "ga 123456", booking.book_number

  end

  def test_parser_no_currency

    test_input =  <<"EOF"
"Supplier","Dagboekcode","Documentnr.","Bedrag"
"ACME","AFGA",123456,-123.45
EOF

    @parser.parse_file(StringIO.new(test_input))

    booking = Booking.first
    assert_equal "ACME", booking.supplier
    assert_in_delta 123.45, booking.amount, 0.0001, "Amount is different : #{booking.amount} vs 123.45"
    assert_equal "ga 123456", booking.book_number

  end

    def test_parser_no_duplicates

      test_input =  <<"EOF"
"Supplier","Dagboekcode","Documentnr.","Bedrag"
"ACME","AFGA",123456,-123.45
"ACME","AFGA",123456,-123.45
EOF

      @parser.parse_file(StringIO.new(test_input))

      assert_equal Booking.all.size, 1

    end

end
