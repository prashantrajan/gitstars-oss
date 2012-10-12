class CreateTaggings < ActiveRecord::Migration
  def change
    create_table :taggings do |t|
      t.integer :tag_id, :null => false
      t.integer :repo_user_id, :null => false
      #t.integer :repo_id, :null => false
      #t.integer :user_id, :null => false

      t.datetime :created_at, :null => false
      #t.timestamps
    end

    add_index :taggings, :tag_id
    add_index :taggings, [:repo_user_id, :tag_id], :unique => true
    #add_index :taggings, [:tag_id, :user_id]
    #add_index :taggings, [:repo_id, :user_id]
    #add_index :taggings, [:user_id, :repo_id, :tag_id], :unique => true
  end
end
