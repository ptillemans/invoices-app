#
# To change this template, choose Tools | Templates
# and open the template in the editor.

require 'roo'
require 'roo-xls'

ORG_MAP = {
  "DEMO" => "Demo",
  "ELEX" => "Elex",
  "EPC"  => "????",
  "MEDU" => "Medussia",
  "SYNE" => "Synegorie",
  "TINA" => "Tina",
  "TVL"  => "TVLokaal",
  "XFAB" => "XFab Silicon Foundries",
  "XTRI" => "Xtrion",
  "XPNV" => "Xpeqt",
}

class ElexInfoParser

  ENCODING='ascii'

  def  self.get_info_from_excel_file(filename)
    lines = []

    wbook = Roo::Spreadsheet.open(filename)

    wsheet = wbook.sheet(0)

    wsheet.each(header_search: ['DokNr', 'Bedrijf', 'BdrVal', 'Adres', 'AnR', 'Barcode']) { |row|

      next if row['DokNr'] == 'DokNr';

      org =  ORG_MAP[row['Bedrijf']]
      book_number = row['DokNr'].to_i.to_s

      unless Booking.where(organization: org, book_number: book_number).first

        info = Booking::new
        info.organization = org
        info.book_number = book_number
        info.amount = row['BdrVal'].to_f
        info.supplier = row['Adres'].to_s
        info.barcode = row['Barcode'].to_i.to_s
        info.reference = row['AnR'].to_s.downcase
        info.save

        lines << info
      end
    }

    return lines
  end
end
