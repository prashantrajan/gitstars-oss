class User < ActiveRecord::Base
  # Available devise modules:
  # :database_authenticatable, :registerable, :recoverable, :validatable,
  # :token_authenticatable, :confirmable, :lockable, :timeoutable
  devise :rememberable, :trackable, :omniauthable


  # Setup accessible (or protected) attributes for your model
  # attr_accessible :email, :password, :password_confirmation, :remember_me

  store :info, :accessors => [:avatar_url, :gravatar_id, :blog_url, :github_url, :bio]

  has_many :repo_users, :dependent => :destroy
  has_many :repos, :through => :repo_users
  has_many :taggings, :through => :repo_users
  has_many :tags, :through => :repo_users, :uniq => true

  validates_presence_of :login, :github_uid
  validates_uniqueness_of :login, :github_uid


  def self.from_github_omniauth(auth)
    user = where(:github_uid => auth.uid).first_or_initialize
    if user.new_record? || user.pre_seeded?
      user.initialize_with_github_info(auth)
      user.save!
    end
    # NOTE: we fetch a user's repos everytime he logs in
    user.fetch_github_starred_repos

    user
  end

  def self.pre_seed(login)
    login = login.downcase
    user = where(:login => login).first_or_initialize

    if user.new_record?
      # TODO: Use a bg job for the api call? This method is currently not being called from a http process, just rake.
      user.initialize_with_github_info(Gitstars::GithubApi.new.get_user(:user => login))
      user.save!
      user.fetch_github_starred_repos
    end

    user
  end

  def self.recent
    where('github_oauth_token IS NOT NULL').order('id DESC')
  end


  def initialize_with_github_info(info)
    base_info, raw_info = nil
    is_omniauth_info = info.respond_to?(:extra) ? true : false

    if is_omniauth_info
      # omniauth library format
      base_info = info.info
      raw_info = info.extra.raw_info
    else
      # github_api library format
      raw_info = info
    end

    self.tap do |u|
      u.email = is_omniauth_info ? base_info.email : nil
      u.login = raw_info.login.downcase
      u.name = is_omniauth_info ? base_info.name : raw_info.name
      u.github_uid = raw_info.id.to_i
      u.github_oauth_token = is_omniauth_info ? info.credentials.token : nil
      u.github_created_at = raw_info.created_at.to_datetime
      u.location = raw_info.location
      u.company = raw_info.company
      u.avatar_url = raw_info.avatar_url
      u.gravatar_id = raw_info.gravatar_id
      u.blog_url = raw_info.blog
      u.github_url = raw_info.html_url
      u.bio = raw_info.bio
    end
  end

  def fetch_github_starred_repos
    Delayed::Job.enqueue FetchGithubStarredReposJob.new(self.id)
  end

  def pre_seeded?
    if new_record? || github_oauth_token.present?
      false
    else
      true
    end
  end

  def to_param
    login
  end

  def gravatar_url(options = {})
    options.stringify_keys!
    size = options['s'] || 32

    # CHANGEME: the hostname for 'd' option
    options = {
      's' => size,
      'd' => "https://raw.github.com/prashantrajan/gitstars-oss/master/app/assets/images/gs_avatar_#{size}.png"
    }.merge(options)

    "http://www.gravatar.com/avatar/#{gravatar_id}?#{options.to_query}"
  end

  def pending_first_github_repos_fetch?
    (!repos.exists?) && pending_github_repos_fetch?
  end

  def pending_github_repos_fetch?
    Delayed::Job.where(:failed_at => nil, :handler => FetchGithubStarredReposJob.new(self.id).to_yaml).exists?
  end

end
