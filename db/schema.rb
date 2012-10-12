# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120821032859) do

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "repo_users", :force => true do |t|
    t.integer  "user_id",    :null => false
    t.integer  "repo_id",    :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "repo_users", ["user_id", "repo_id"], :name => "index_repo_users_on_user_id_and_repo_id", :unique => true

  create_table "repos", :force => true do |t|
    t.integer  "github_identifier",                :null => false
    t.string   "name",                             :null => false
    t.string   "owner_login",                      :null => false
    t.string   "full_name",                        :null => false
    t.text     "description"
    t.string   "primary_language"
    t.integer  "forks",             :default => 0
    t.integer  "stargazers",        :default => 0
    t.datetime "github_created_at"
    t.datetime "github_updated_at"
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
    t.text     "properties"
  end

  add_index "repos", ["full_name"], :name => "index_repos_on_full_name", :unique => true
  add_index "repos", ["github_identifier"], :name => "index_repos_on_github_identifier", :unique => true
  add_index "repos", ["owner_login"], :name => "index_repos_on_owner_login"

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id",       :null => false
    t.integer  "repo_user_id", :null => false
    t.datetime "created_at",   :null => false
  end

  add_index "taggings", ["repo_user_id", "tag_id"], :name => "index_taggings_on_repo_user_id_and_tag_id", :unique => true
  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"

  create_table "tags", :force => true do |t|
    t.string "name", :null => false
    t.string "slug", :null => false
  end

  add_index "tags", ["name"], :name => "index_tags_on_name", :unique => true
  add_index "tags", ["slug"], :name => "index_tags_on_slug", :unique => true

  create_table "users", :force => true do |t|
    t.string   "email"
    t.string   "login",                              :null => false
    t.string   "name"
    t.integer  "github_uid"
    t.string   "github_oauth_token"
    t.datetime "github_created_at"
    t.string   "location"
    t.string   "company"
    t.text     "info"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",       :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
  end

  add_index "users", ["github_uid"], :name => "index_users_on_github_uid", :unique => true
  add_index "users", ["login"], :name => "index_users_on_login", :unique => true

end
