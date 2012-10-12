require 'spec_helper'

describe FetchGithubStarredReposJob do

  describe "#perform" do
    context "when given user has auth tokens" do
      let!(:user) { FactoryGirl.create(:real_github_user) }
      let!(:github_api) { Gitstars::GithubApi.new(:oauth_token => user.github_oauth_token) }

      it "fetches and creates the given user's public starred repos" do
        mock_results = []
        Gitstars::GithubApi.should_receive(:new).with(:oauth_token => user.github_oauth_token).ordered { github_api }
        github_api.should_receive(:get_user_starred_repos).with(:user => user.login).ordered { mock_results }
        Repo.should_receive(:create_from_github).with(mock_results, user).ordered

        FetchGithubStarredReposJob.new(user.id).perform
      end
    end

    context "when given user does not have auth tokens" do
      let!(:user) { FactoryGirl.create(:pre_seeded_user) }
      let!(:github_api) { Gitstars::GithubApi.new(:oauth_token => user.github_oauth_token) }

      it "fetches and creates the given user's public starred repos" do
        expect(user.github_oauth_token).to be_nil

        mock_results = []
        Gitstars::GithubApi.should_receive(:new).with(:oauth_token => user.github_oauth_token).ordered { github_api }
        github_api.should_receive(:get_user_starred_repos).with(:user => user.login).ordered { mock_results }
        Repo.should_receive(:create_from_github).with(mock_results, user).ordered

        FetchGithubStarredReposJob.new(user.id).perform
      end
    end
  end

end
