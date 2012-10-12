class Repo < ActiveRecord::Base

  store :properties, :accessors => [:github_url, :tag_list]

  has_many :repo_users, :dependent => :destroy
  has_many :users, :through => :repo_users
  has_many :taggings, :through => :repo_users
  has_many :tags, :through => :repo_users, :uniq => true

  before_create :sanitize_tag_list


  paginates_per 50


  def self.create_from_github(raw_repos_arr, user = nil)
    raw_repos_arr.each do |raw_repo|
      repo = where(:github_identifier => raw_repo.id).first_or_create do |r|
        r.github_identifier = raw_repo.id
        r.name = raw_repo.name
        r.owner_login = raw_repo.owner.login
        r.full_name = raw_repo.full_name
        r.description = raw_repo.description
        r.primary_language = raw_repo.language
        r.forks = raw_repo.forks
        r.stargazers = raw_repo.watchers
        r.github_created_at = raw_repo.created_at.to_datetime
        r.github_updated_at = raw_repo.updated_at.to_datetime
        r.github_url = raw_repo.html_url
      end

      if user
        user.repo_users.where(:repo_id => repo.id).first_or_create
      end
    end
  end

  def self.set_tag_list
    # TODO: we don't need to do this for all repos, all the time - only do this based on new taggings
    # TODO: move this into bg job; one job per repo?
    Repo.order(:name).each do |repo|
      repo.tag_list = Tag.recommended_list_for_repo(repo)
      repo.save
    end
  end


  def github_user_url
    "https://github.com/#{owner_login}"
  end

  def github_repo_url
    github_url
  end


  private

  def sanitize_tag_list
    if tag_list.present?
      unless tag_list.kind_of?(Array)
        self.tag_list = tag_list.to_s.split(',')
      end
    else
      self.tag_list = primary_language.present? ? [primary_language] : []
    end
  end

end
