require 'spec_helper'

describe RepoUser do

  describe "associations" do
    it { should belong_to(:user) }
    it { should belong_to(:repo) }

    it { should have_many(:taggings).dependent(:destroy) }
    it { should have_many(:tags).through(:taggings) }
  end

  describe "validations" do
    before(:each) do
      FactoryGirl.create(:repo_user)
    end

    it { should validate_uniqueness_of(:user_id).scoped_to(:repo_id) }
  end

  describe "after_create" do
    describe "#create_default_taggings" do
      let(:user) { FactoryGirl.create(:user) }
      let(:repo) { FactoryGirl.create(:repo, :tag_list => ['FooBarX']) }

      it "create default taggings based on the repos' tag_list" do
        repo_user = nil
        expect {
          repo_user = RepoUser.create(:user => user, :repo => repo)
        }.to change { user.taggings.count }.by(1)

        tagging = repo_user.taggings.first
        expect(tagging.tag.name).to eq('FooBarX')
      end
    end
  end

  describe "#tag_tokens" do
    it "responds to #tag_tokens" do
      expect(RepoUser.new).to respond_to(:tag_tokens)
    end
  end

  describe "#tag_tokens=" do
    let!(:tag1) { Tag.create(:name => 'Hello World') }
    let!(:tag2) { Tag.create(:name => 'foobaz') }
    let!(:tag3) { Tag.create(:name => 'ruby') }
    let!(:repo_user) { FactoryGirl.create(:repo_user) }

    before(:each) do
      repo_user.tag_ids = Tag.pluck(:id)
    end

    it "sets the tag_ids based on the given tokens" do
      tokens = "#{tag3.id},#{tag1.id}"
      repo_user.tag_tokens = tokens
      expect(repo_user.tag_ids).to match_array(tokens.split(',').map(&:to_i))
    end
  end

end
