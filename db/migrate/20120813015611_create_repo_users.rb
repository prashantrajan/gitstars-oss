class CreateRepoUsers < ActiveRecord::Migration
  def change
    create_table :repo_users do |t|
      t.integer :user_id, :null => false
      t.integer :repo_id, :null => false
      t.timestamps
    end

    add_index :repo_users, [:user_id, :repo_id], :unique => true
  end
end
