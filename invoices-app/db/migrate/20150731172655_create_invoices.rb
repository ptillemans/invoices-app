class CreateInvoices < ActiveRecord::Migration
  def change
    unless ActiveRecord::Base.connection.table_exists? 'invoices'
      create_table :invoices do |t|
        t.column :organization, :string
        t.column :book_number, :string
        t.column :approver, :string
        t.column :file_name, :string
        t.column :uploaded, :integer
        t.column :jira_id, :string
        t.column :jira_status, :string
      end
    end
  end
end
