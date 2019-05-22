class AddOrganizationIdToInvoices < ActiveRecord::Migration
  def change
    add_column :invoices, :organization_id, :int

    reversible do |dir|

      dir.up {
        Invoice.all.each {  |inv|
          org = Organization.find_or_create_by(name: inv.read_attribute(:organization))
          inv.organization = org
          inv.save

        }
      }
    end
  end


end
