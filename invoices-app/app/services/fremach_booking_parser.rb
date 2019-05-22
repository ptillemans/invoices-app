#
# To change this template, choose Tools | Templates
# and open the template in the editor.
require 'csv'

class FremachBookingParser

  THOUSAND_SEPARATOR = ','

  def initialize(org)
    @organization = org
  end

  # find the columns for the supplier, datebookcode, bookingnumber and amount
  #
  #   Due to the changing nature of these manually created report we can build
  # some robustness by finding the columns dynamically
  def parse_title_row(row)
    @col_amount = row.index("Bedrag") || row.index("bedrag")
    @col_supplier = row.index("Supplier") || row.index("supplier")
    @col_code = row.index("Dagboekcode") || row.index("dagboekcode")
    @col_number = row.index("Documentnr.") || row.index("documentnr.")
  end

  def clean_amount(amount)
    # remove thousand separator
    amount = amount.sub(THOUSAND_SEPARATOR, '')


    sp = (amount == nil ? 0 : amount.index(' '));
    #puts "#{amount} --> #{sp}"
    if sp then
      # remove currency
      amount = amount.slice(0,sp)
    end

    return - amount.to_f

  end


  def parse_data_row(row)
    dbc = row[@col_code].downcase.sub('af', '')
    book_number = dbc + ' ' + row[@col_number]
    unless Booking.where(organization: @organization, book_number: book_number).first
      bi = Booking.new
      bi.organization = @organization
      bi.book_number = book_number
      bi.supplier = row[@col_supplier]
      bi.amount = clean_amount(row[@col_amount])
      bi.uploaded = false
      bi.save
    end

  end

  def parse_file(io)
    first_line = true
    CSV.new(io).each { |row|
      if first_line
        parse_title_row(row)
        first_line = false
      else
        parse_data_row(row)
      end
    }
  end

end
