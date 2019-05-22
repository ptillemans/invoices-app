class AddResultToInvoices < ActiveRecord::Migration
  def change
    add_column :invoices, :result, :text
  end
end
