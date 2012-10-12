class AddIndexToUsersGithubUid < ActiveRecord::Migration
  def change
    add_index :users, :github_uid, :unique => true
  end
end
