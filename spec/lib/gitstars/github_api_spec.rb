require 'spec_helper'

describe Gitstars::GithubApi do

  describe "#initialize" do
    it "sets the client attribute to an instance of Github::Client" do
      expect(Gitstars::GithubApi.new.client).to be_an_instance_of(Github::Client)
    end

    it "passes on the given options to Github::Client" do
      expect(Gitstars::GithubApi.new(:oauth_token => 'foobar_token').client.oauth_token).to eq('foobar_token')
    end
  end

  describe "#get_user_starred_repos" do
    let!(:user) { FactoryGirl.create(:real_github_user) }

    after(:each) do
      github_api_reset_authentication_for(github_api)
    end

    context "when user is authenticated", :vcr => {:cassette_name => 'github/repos/watching/watched/authenticated'} do
      let!(:github_api) { Github.new(:oauth_token => user.github_oauth_token) }

      it "returns the given authenticated user's starred repos" do
        expected = github_api.repos.watching.watched(:per_page => 100)
        results = Gitstars::GithubApi.new(:oauth_token => user.github_oauth_token).get_user_starred_repos
        expect(results).to eq(expected)
      end
    end

    context "when user is not authenticated", :vcr => {:cassette_name => 'github/repos/watching/watched/unauthenticated'} do
      # TODO: buggy somewhere causing indeterministic suite failure so need to pass :oauth_token => nil
      let!(:github_api) { Github.new(:oauth_token => nil) }

      it "returns the given user's starred repos" do
        expected = github_api.repos.watching.watched(:per_page => 100, :user => user.login)
        results = Gitstars::GithubApi.new.get_user_starred_repos(:user => user.login)
        expect(results).to eq(expected)
      end
    end
  end

  describe "#get_user" do
    let!(:user) { FactoryGirl.create(:real_github_user) }

    after(:each) do
      github_api_reset_authentication_for(github_api)
    end

    context "when user is authenticated", :vcr => {:cassette_name => 'github/users/authenticated'} do
      let!(:github_api) { Github.new(:oauth_token => user.github_oauth_token) }

      it "returns the given authenticated user's info" do
        expected = github_api.users.get
        results = Gitstars::GithubApi.new(:oauth_token => user.github_oauth_token).get_user
        expect(results).to eq(expected)
      end
    end

    context "when user is not authenticated", :vcr => {:cassette_name => 'github/users/unauthenticated'} do
      # TODO: buggy somewhere causing indeterministic suite failure so need to pass :oauth_token => nil
      let!(:github_api) { Github.new(:oauth_token => nil) }

      it "returns the given user's info" do
        expected = github_api.users.get(:user => user.login)
        results = Gitstars::GithubApi.new.get_user(:user => user.login)
        expect(results).to eq(expected)
      end
    end
  end

end
