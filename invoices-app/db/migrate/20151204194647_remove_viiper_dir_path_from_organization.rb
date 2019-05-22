class RemoveViiperDirPathFromOrganization < ActiveRecord::Migration
  def change
    remove_column :organizations, :viiper_dir_path, :string
  end
end
