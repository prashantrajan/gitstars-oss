class CreateRepos < ActiveRecord::Migration
  def change
    create_table :repos do |t|
      t.integer :github_identifier, :null => false
      t.string :name, :null => false
      t.string :owner_login, :null => false
      t.string :full_name, :null => false
      t.text :description
      t.string :primary_language
      t.integer :forks, :default => 0
      t.integer :stargazers, :default => 0
      t.datetime :github_created_at
      t.datetime :github_updated_at
      t.timestamps
      t.text :properties
    end

    add_index :repos, :github_identifier, :unique => true
    add_index :repos, :full_name, :unique => true
    add_index :repos, :owner_login
  end
end
