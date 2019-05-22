class CreateOrganizations < ActiveRecord::Migration
  def change
    create_table :organizations do |t|
      t.string :name, null: false
      t.string :default_approver, null: true
      t.string :backend, null: false, default: 'jira'
    end
  end
end
