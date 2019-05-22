class AddUniqueIndexOnUsers < ActiveRecord::Migration
  def change

    # remove duplicate users
    User.group(:username).each do |user|
      User.destroy_all("username = '#{user.username}' and id <> #{user.id}")
    end

    remove_index :users, :username
    add_index :users, :username, :unique => true
  end
end
