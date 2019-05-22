class CreateInvoicesOrganizations < ActiveRecord::Migration
  def change
    create_table :invoices_organizations do |t|

      t.timestamps null: false
    end
  end
end
