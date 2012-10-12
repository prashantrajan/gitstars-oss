module Gitstars

  class GithubApi
    attr_accessor :client

    def initialize(options = {})
      self.client = Github.new(options)
    end

    def get_user_starred_repos(options = {})
      raw_repos = []
      options.delete(:user) if client.oauth_token.present?

      results = client.repos.watching.watched({:per_page => 100}.merge(options))
      results.each_page do |page|
        page.each do |repo|
          raw_repos << repo
        end
      end

      raw_repos
    end

    def get_user(options = {})
      options.delete(:user) if client.oauth_token.present?
      client.users.get(options)
    end
  end

end
