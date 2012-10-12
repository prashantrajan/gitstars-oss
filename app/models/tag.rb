class Tag < ActiveRecord::Base

  has_many :taggings, :dependent => :destroy
  has_many :repo_users, :through => :taggings
  has_many :repos, :through => :repo_users, :source => :repo, :uniq => true

  validates_presence_of :name, :slug
  validates_uniqueness_of :name, :slug
  validates_format_of :name, :with => /\A[a-z0-9\#\+\&\.\_\-\s]+\Z/i

  before_validation :sanitize_name
  before_validation :slugify

  def self.by_token(token)
    tags = find_all_by_name_ci("#{token}%").order(:name).limit(AppSettings.tag_autocomplete_results_limit)
    is_exact_match = tags.any? { |tag| tag.name.downcase == token.downcase }

    is_exact_match ? tags : tags.append({:id => "<<<#{token}>>>", :name => "New: #{token}"})
  end

  def self.ids_from_tokens(tokens)
    tokens.gsub!(/<<<(.+?)>>>/) { find_all_by_name_ci($1).first_or_create(:name => $1).id }
    tokens.split(',').uniq
  end

  def self.site_wide
    joins(:taggings).uniq.order(:name)
  end

  def self.popular_site_wide
    select('tags.name, tags.slug, count(*) as total').joins(:repos).group('tags.name, tags.slug').order('total DESC')
  end

  def self.popular_for_user(user)
    user.tags.select('tags.name, tags.slug, count(*) as total').scoped.uniq(false).group('tags.name, tags.slug').order('total DESC')
  end

  def self.recommended_list_for_repo(repo)
    results = select('tags.name, count(*) as total').joins(:repos).where(:repos => {:id => repo.id}).group('tags.name').order('total DESC').limit(5).map(&:name)
    results.prepend(repo.primary_language) if repo.primary_language.present?
    results.uniq
  end

  def self.find_all_by_name_ci(name)
    where("name ILIKE ?", name)
  end

  def to_param
    slug
  end


  private

  def sanitize_name
    self.name = name.to_s.squish
  end

  def slugify
    self.slug = name.to_s.parameterize unless slug.present?
  end

end
