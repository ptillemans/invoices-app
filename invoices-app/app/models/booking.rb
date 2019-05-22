require('active_record')
require('active_support')

class Booking  < ActiveRecord::Base

  def to_s
    return "(#{organization}) Booking #{book_number} for #{amount} from #{supplier}"
  end


end
