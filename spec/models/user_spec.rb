require 'spec_helper'

describe User do

  describe "associations" do
    it { should have_many(:repo_users).dependent(:destroy) }
    it { should have_many(:repos).through(:repo_users) }

    it { should have_many(:taggings).through(:repo_users) }
    it { should have_many(:tags).through(:repo_users) }
  end

  describe "validations" do
    before(:each) do
      FactoryGirl.create(:user, :login => 'mrsmith')
    end

    it { should validate_presence_of(:login) }
    it { should validate_uniqueness_of(:login) }

    it { should validate_presence_of(:github_uid) }
    it { should validate_uniqueness_of(:github_uid) }
  end

  describe "#info key-value store" do
    let(:user) { User.new }

    it "supports accessing attributes via #info hash" do
      expect(user.info).to be_an_instance_of(Hash)
    end

    it "supports custom accessors for stored attributes" do
      expect(user).to respond_to(:avatar_url)
      expect(user).to respond_to(:gravatar_id)
      expect(user).to respond_to(:blog_url)
      expect(user).to respond_to(:github_url)
      expect(user).to respond_to(:bio)
    end
  end


  describe ".from_github_omniauth" do
    let!(:auth) { github_successful_auth_response }
    let!(:raw_info) { auth.extra.raw_info }

    context "new auth", :vcr => {:cassette_name => 'github/repos/watching/watched/authenticated'} do
      it "creates a new user" do
        expect {
          User.from_github_omniauth(auth)
        }.to change { User.count }.by(1)
      end

      it "sets the user attributes" do
        user = User.from_github_omniauth(auth)

        expect(user.email).to eq(auth.info.email)
        expect(user.login).to eq(raw_info.login)
        expect(user.name).to eq(auth.info.name)
        expect(user.github_uid).to eq(raw_info.id)
        expect(user.github_oauth_token).to eq(auth.credentials.token)
        expect(user.location).to eq(raw_info.location)
        expect(user.company).to eq(raw_info.company)
        expect(user.avatar_url).to eq(raw_info.avatar_url)
        expect(user.gravatar_id).to eq(raw_info.gravatar_id)
        expect(user.blog_url).to eq(raw_info.blog)
        expect(user.github_url).to eq(raw_info.html_url)
        expect(user.bio).to eq(raw_info.bio)
        expect(user.github_created_at).to eq(raw_info.created_at.to_datetime)
      end

      it "returns a user object" do
        expect(User.from_github_omniauth(auth)).to be_instance_of(User)
      end

      it "enqueues a FetchGithubStarredReposJob" do
        user = nil

        expect {
          user = User.from_github_omniauth(auth)
        }.to change { Delayed::Job.count }.by(1)

        expect(Delayed::Job.last.handler).to eq(FetchGithubStarredReposJob.new(user.id).to_yaml)
      end

      context "pre_seeded user" do
        let!(:user) { FactoryGirl.create(:pre_seeded_user) }

        it "sets the missing user attributes" do
          user = User.from_github_omniauth(auth)

          expect(user.email).to eq(auth.info.email)
          expect(user.login).to eq(raw_info.login)
          expect(user.name).to eq(auth.info.name)
          expect(user.github_oauth_token).to eq(auth.credentials.token)
        end
      end
    end

    context "existing auth" do
      let!(:user) { FactoryGirl.create(:real_github_user) }

      it "does not create a new user record" do
        expect {
          User.from_github_omniauth(auth)
        }.to_not change { User.count }
      end

      it "does not update the user's info" do
        User.any_instance.should_not_receive(:initialize_with_github_info).with(auth)

        User.from_github_omniauth(auth)
      end

      it "returns the existing user" do
        expect(User.from_github_omniauth(auth)).to eq(user)
      end

      it "enqueues a FetchGithubStarredReposJob" do
        expect {
          user = User.from_github_omniauth(auth)
        }.to change { Delayed::Job.count }.by(1)

        expect(Delayed::Job.last.handler).to eq(FetchGithubStarredReposJob.new(user.id).to_yaml)
      end
    end
  end

  describe ".pre_seed" do
    context "new user", :vcr => {:cassette_name => 'github/unauthenticated_user_and_repo_watched_info'} do
      let!(:login) { FactoryGirl.build(:real_github_user).login }

      it "creates a new user record" do
        expect {
          User.pre_seed(login)
        }.to change{ User.count }.by(1)
      end

      it "enqueues a FetchGithubStarredReposJob" do
        user = nil

        expect {
          user = User.pre_seed(login)
        }.to change { Delayed::Job.count }.by(1)

        expect(Delayed::Job.last.handler).to eq(FetchGithubStarredReposJob.new(user.id).to_yaml)
      end

      it "returns the newly created user record" do
        expect(User.pre_seed(login)).to eq(User.find_by_login(login))
      end
    end

    context "user already exists in system" do
      let!(:user) { FactoryGirl.create(:user) }

      it "does not create a new user record" do
        expect {
          User.pre_seed(user.login)
        }.to_not change { User.count }
      end

      it "returns the existing user record" do
        expect(User.pre_seed(user.login)).to eq(user)
      end
    end
  end


  describe "#initialize_with_github_info" do
    let!(:user) { FactoryGirl.build(:real_github_user) }

    context "info is from omniauth library" do
      let!(:info) { github_successful_auth_response }

      it "sets the user attributes" do
        user.initialize_with_github_info(info)
        user.save!

        base_info = info.info
        raw_info = info.extra.raw_info

        expect(user.email).to eq(base_info.email)
        expect(user.login).to eq(raw_info.login)
        expect(user.name).to eq(base_info.name)
        expect(user.github_uid).to eq(raw_info.id)
        expect(user.github_oauth_token).to eq(info.credentials.token)
        expect(user.github_created_at).to eq(raw_info.created_at.to_datetime)
        expect(user.location).to eq(raw_info.location)
        expect(user.company).to eq(raw_info.company)
        expect(user.avatar_url).to eq(raw_info.avatar_url)
        expect(user.gravatar_id).to eq(raw_info.gravatar_id)
        expect(user.blog_url).to eq(raw_info.blog)
        expect(user.github_url).to eq(raw_info.html_url)
        expect(user.bio).to eq(raw_info.bio)
      end
    end

    context "info is from github_api library", :vcr => {:cassette_name => 'github/users/unauthenticated'} do
      # TODO: buggy somewhere causing indeterministic suite failure so need to pass :oauth_token => nil
      let!(:gs_github_api) { Gitstars::GithubApi.new(:oauth_token => nil) }
      let!(:info) { gs_github_api.get_user(:user => user.login) }

      after(:each) do
        github_api_reset_authentication_for(gs_github_api.client)
      end

      it "sets the user attributes" do
        user.initialize_with_github_info(info)
        user.save!

        raw_info = info

        expect(user.email).to be_nil
        expect(user.login).to eq(raw_info.login)
        expect(user.name).to eq(raw_info.name)
        expect(user.github_uid).to eq(raw_info.id)
        expect(user.github_oauth_token).to be_nil
        expect(user.github_created_at).to eq(raw_info.created_at.to_datetime)
        expect(user.location).to eq(raw_info.location)
        expect(user.company).to eq(raw_info.company)
        expect(user.avatar_url).to eq(raw_info.avatar_url)
        expect(user.gravatar_id).to eq(raw_info.gravatar_id)
        expect(user.blog_url).to eq(raw_info.blog)
        expect(user.github_url).to eq(raw_info.html_url)
        expect(user.bio).to eq(raw_info.bio)
      end
    end
  end

  describe "#pre_seeded?" do
    context "user record just initialized" do
      it "returns false" do
        expect(User.new.pre_seeded?).to be_false
      end
    end

    context "user has a github_oauth_token" do
      it "returns false" do
        user = FactoryGirl.create(:real_github_user)
        expect(user.pre_seeded?).to be_false
      end
    end

    context "user does not have a github_oauth_token" do
      it "returns true" do
        user = FactoryGirl.create(:user)
        expect(user.pre_seeded?).to be_true
      end
    end
  end

  describe "#to_param" do
    it "returns the login" do
      user = FactoryGirl.create(:user, :login => 'foobarl337')
      expect(user.to_param).to eq('foobarl337')
    end
  end

  describe "#gravatar_url" do
    let!(:user) { FactoryGirl.create(:user) }
    let(:base_default_avatar_url) { "http://www.gitstars.com/assets" }

    context "no custom options are sent" do
      it "returns a gravatar url with a default image size of 32" do
        size = 32
        options = {
          :d => "http://www.gitstars.com/assets/gs_avatar_#{size}.png",
          :s => size
        }

        expect(user.gravatar_url).to eq("http://www.gravatar.com/avatar/#{user.gravatar_id}?#{options.to_query}")
      end
    end

    context "when custom options are sent" do
      it "returns a customized gravatar url with a default GS avatar at that size" do
        size = 24

        options = {
          :d => "http://www.gitstars.com/assets/gs_avatar_#{size}.png",
          :s => size
        }

        expect(user.gravatar_url(:s => size)).to eq("http://www.gravatar.com/avatar/#{user.gravatar_id}?#{options.to_query}")
      end
    end
  end

  describe "#pending_first_github_repos_fetch?" do
    let!(:user) { FactoryGirl.create(:user) }

    before(:each) do
      Delayed::Worker.delay_jobs = true
    end

    context "user has associated repos" do
      before(:each) do
        FactoryGirl.create(:repo_user, :user => user)
      end

      it "returns false" do
        expect(user.pending_first_github_repos_fetch?).to be_false
      end
    end

    context "user does not have any associated repos" do
      context "and does not have a pending FetchGithubStarredReposJob" do
        it "returns false" do
          expect(user.pending_first_github_repos_fetch?).to be_false
        end
      end

      context "and has a pending FetchGithubStarredReposJob" do
        before(:each) do
          Delayed::Job.enqueue(FetchGithubStarredReposJob.new(user.id))
        end

        it "returns true" do
          expect(user.pending_first_github_repos_fetch?).to be_true
        end
      end
    end
  end

  describe "#pending_github_repos_fetch?" do
    let!(:user) { FactoryGirl.create(:user) }

    before(:each) do
      Delayed::Worker.delay_jobs = true
    end

    context "user has no pending FetchGithubStarredReposJob" do
      it "returns false" do
        expect(user.pending_github_repos_fetch?).to be_false
      end
    end

    context "user has pending FetchGithubStarredReposJob" do
      before(:each) do
        Delayed::Job.enqueue(FetchGithubStarredReposJob.new(user.id))
      end

      it "returns true" do
        expect(user.pending_github_repos_fetch?).to be_true
      end
    end
  end

end
