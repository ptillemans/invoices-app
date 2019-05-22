class AddIndexToInvoices < ActiveRecord::Migration
  def change
    add_index :invoices, :book_number
  end
end
