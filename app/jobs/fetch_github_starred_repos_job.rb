class FetchGithubStarredReposJob < Struct.new(:user_id)

  def perform
    user = User.find(user_id)

    # NOTE: when :oauth_token is present, the :user option is stripped automatically by Gitstars::GithubApi
    results = Gitstars::GithubApi.new(:oauth_token => user.github_oauth_token).get_user_starred_repos(:user => user.login)
    Repo.create_from_github(results, user)
  end

end
