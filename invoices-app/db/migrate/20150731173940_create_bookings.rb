class CreateBookings < ActiveRecord::Migration
  def change
    unless ActiveRecord::Base.connection.table_exists? 'bookings'
      create_table :bookings do |t|
        t.column :organization, :string
        t.column :book_number, :string
        t.column :supplier, :string
        t.column :reference, :string
        t.column :amount, :number
        t.column :barcode, :string
        t.column :uploaded, :integer, {:default => 0}
      end
    end
  end
end
