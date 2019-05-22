class AddTimestamps < ActiveRecord::Migration
  def change
    reversible do |dir|
      # invoices
      add_column(:invoices, :created_at, :datetime)
      add_column(:invoices, :updated_at, :datetime)
      dir.up {
        Invoice.update_all(:created_at => Time.now)
        Invoice.update_all(:updated_at => Time.now)
      }

      # organizations
      add_column(:organizations, :created_at, :datetime)
      add_column(:organizations, :updated_at, :datetime)
      dir.up {
        Organization.update_all(:created_at => Time.now)
        Organization.update_all(:updated_at => Time.now)
      }


      # bookings
      add_column(:bookings, :created_at, :datetime)
      add_column(:bookings, :updated_at, :datetime)
      dir.up {
        Booking.update_all(:created_at => Time.now)
        Booking.update_all(:updated_at => Time.now)
      }

    end
  end
end
