class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|

      t.string    :username, null:false
      t.boolean   :admin, default: false
      t.boolean   :reader, default: false

      t.timestamps null: false
    end
    add_index :users, :username
  end
end
