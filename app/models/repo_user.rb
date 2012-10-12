class RepoUser < ActiveRecord::Base
  attr_reader :tag_tokens

  belongs_to :user
  belongs_to :repo

  has_many :taggings, :dependent => :destroy
  has_many :tags, :through => :taggings

  validates_uniqueness_of :user_id, :scope => :repo_id

  after_create :create_default_taggings


  paginates_per 50


  def tag_tokens=(tokens)
    self.tag_ids = Tag.ids_from_tokens(tokens)
  end


  private

  def create_default_taggings
    if repo.tag_list.present?
      repo.tag_list.each do |tag_name|
        tag = Tag.find_all_by_name_ci(tag_name).first_or_create(:name => tag_name)
        self.taggings.create(:tag => tag)
      end
    end
  end

end
