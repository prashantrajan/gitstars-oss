class Tagging < ActiveRecord::Base

  belongs_to :tag
  belongs_to :repo_user

  validates_uniqueness_of :repo_user_id, :scope => :tag_id

end
