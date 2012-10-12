require 'spec_helper'

describe Repo do

  describe "associations" do
    it { should have_many(:repo_users).dependent(:destroy) }
    it { should have_many(:users).through(:repo_users) }

    it { should have_many(:taggings).through(:repo_users) }
    it { should have_many(:tags).through(:repo_users) }
  end

  describe "before_create" do
    describe "#sanitize_tag_list" do
      context "when tag_list is an array" do
        it "uses the array as is" do
          tag_list = ['foo', 'bar', 'baz']
          repo = FactoryGirl.create(:repo, :tag_list => tag_list)

          expect(repo.tag_list).to match_array(tag_list)
        end
      end

      context "when tag_list is a string" do
        it "converts the tag_list into an array" do
          tag_list = 'foo,bar,baz'
          repo = FactoryGirl.create(:repo, :tag_list => tag_list)

          expect(repo.tag_list).to match_array(tag_list.split(','))
        end
      end

      context "when tag_list is nil" do
        it "converts the tag_list into an empty array" do
          repo = FactoryGirl.create(:repo, :tag_list => nil)
          expect(repo.tag_list).to eq([])
        end
      end
    end
  end

  describe "#properties key-value store" do
    let(:repo) { Repo.new }

    it "supports accessing attributes via #properties hash" do
      expect(repo.properties).to be_an_instance_of(Hash)
    end

    it "supports custom accessors for stored attributes" do
      expect(repo).to respond_to(:github_url)
      expect(repo).to respond_to(:tag_list)
    end
  end


  describe ".create_from_github", :vcr => {:cassette_name => 'github/repos/watching/watched/authenticated'} do
    let!(:user) { FactoryGirl.create(:real_github_user) }
    let!(:gs_github_api) { Gitstars::GithubApi.new(:oauth_token => user.github_oauth_token) }
    let!(:raw_repos_arr) { gs_github_api.get_user_starred_repos }

    after(:each) do
      github_api_reset_authentication_for(gs_github_api.client)
    end

    it "creates repos from the API results" do
      expect {
        Repo.create_from_github(raw_repos_arr)
      }.to change{ Repo.count }.by(raw_repos_arr.size)
    end

    it "sets the repo attributes" do
      Repo.create_from_github(raw_repos_arr)

      raw_repo = raw_repos_arr.first
      repo = Repo.first

      expect(repo.github_identifier).to eq(raw_repo.id)
      expect(repo.name).to eq(raw_repo.name)
      expect(repo.owner_login).to eq(raw_repo.owner.login)
      expect(repo.full_name).to eq(raw_repo.full_name)
      expect(repo.description).to eq(raw_repo.description)
      expect(repo.primary_language).to eq(raw_repo.language)
      expect(repo.tag_list).to eq([raw_repo.language])
      expect(repo.forks).to eq(raw_repo.forks)
      expect(repo.stargazers).to eq(raw_repo.watchers)
      expect(repo.github_created_at).to eq(raw_repo.created_at.to_datetime)
      expect(repo.github_updated_at).to eq(raw_repo.updated_at.to_datetime)
      expect(repo.github_url).to eq(raw_repo.html_url)
    end

    it "does not create duplicate repos" do
      Repo.create_from_github(raw_repos_arr)

      expect {
        Repo.create_from_github(raw_repos_arr)
      }.to_not change { Repo.count }
    end

    context "when a user object is given" do
      it "creates an association between the repos and the given user" do
        Repo.create_from_github(raw_repos_arr, user)

        expect(user.repos.count).to eq(raw_repos_arr.size)
        expect(user.repo_users.count).to eq(raw_repos_arr.size)
      end

      context "when the given user already has an association with the repo" do
        it "does not create a new association" do
          Repo.create_from_github(raw_repos_arr)

          expect {
            Repo.create_from_github(raw_repos_arr)
          }.to_not change { user.repo_users.count }
        end
      end
    end
  end

  describe ".set_tag_list" do
    let!(:repo1) { FactoryGirl.create(:repo, :primary_language => 'C') }
    let!(:repo2) { FactoryGirl.create(:repo, :primary_language => 'JavaScript') }

    before(:each) do
      Repo.set_tag_list
      repo1.reload
      repo2.reload
    end

    it "sets the tag_list for all repos" do
      expect(repo1.tag_list).to eq(['C'])
      expect(repo2.tag_list).to eq(['JavaScript'])
    end
  end


  describe "#github_user_url" do
    let!(:repo) { FactoryGirl.create(:repo) }

    it "returns the repo owner's github profile url" do
      expect(repo.github_user_url).to eq("https://github.com/#{repo.owner_login}")
    end
  end

  describe "#github_repo_url" do
    let!(:repo) { FactoryGirl.create(:repo) }

    it "returns the repo github url" do
      expect(repo.github_repo_url).to eq("https://github.com/#{repo.full_name}")
    end
  end

end
