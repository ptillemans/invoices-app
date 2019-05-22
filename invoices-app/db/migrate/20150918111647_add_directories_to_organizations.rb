class AddDirectoriesToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :viiper_dir_name, :string
    add_column :organizations, :viiper_dir_path, :string
  end
end
