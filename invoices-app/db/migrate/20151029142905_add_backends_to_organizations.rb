class AddBackendsToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :backends, :text, :default => ["jira"].to_yaml()

    reversible do |dir|

      dir.up {
        Organization.all.each { |org|
          puts "Migrating backend #{org.backend}"
          org.backends = [ org.backend ]
          puts "  ---> #{org.backends}"
          org.save
        }
      }
    end
  end
end
