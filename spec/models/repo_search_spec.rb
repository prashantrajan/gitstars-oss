require 'spec_helper'

describe RepoSearch do

  describe ".self.all_by_tag_ids" do
    let!(:user1) { FactoryGirl.create(:user) }
    let!(:user2) { FactoryGirl.create(:user) }

    let!(:tag1) { FactoryGirl.create(:tag, :name => 'tag1') }
    let!(:tag2) { FactoryGirl.create(:tag, :name => 'tag2') }
    let!(:tag3) { FactoryGirl.create(:tag, :name => 'tag3') }

    let!(:repo1) { FactoryGirl.create(:repo, :name => 'repo1', :stargazers => 5) }
    let!(:repo2) { FactoryGirl.create(:repo, :name => 'repo2', :stargazers => 20) }
    let!(:repo3) { FactoryGirl.create(:repo, :name => 'repo3', :stargazers => 10) }

    let!(:user1_repo_user1) { FactoryGirl.create(:repo_user, :user => user1, :repo => repo1) }
    let!(:user1_repo_user1_tagging1) { FactoryGirl.create(:tagging, :repo_user => user1_repo_user1, :tag => tag1) }
    let!(:user1_repo_user1_tagging2) { FactoryGirl.create(:tagging, :repo_user => user1_repo_user1, :tag => tag2) }

    let!(:user1_repo_user2) { FactoryGirl.create(:repo_user, :user => user1, :repo => repo3) }
    let!(:user1_repo_user2_tagging1) { FactoryGirl.create(:tagging, :repo_user => user1_repo_user2, :tag => tag1) }

    let!(:user2_repo_user1) { FactoryGirl.create(:repo_user, :user => user2, :repo => repo1) }
    let!(:user2_repo_user1_tagging1) { FactoryGirl.create(:tagging, :repo_user => user2_repo_user1, :tag => tag2) }

    let!(:user2_repo_user2) { FactoryGirl.create(:repo_user, :user => user2, :repo => repo2) }
    let!(:user2_repo_user2_tagging1) { FactoryGirl.create(:tagging, :repo_user => user2_repo_user2, :tag => tag2) }
    let!(:user2_repo_user2_tagging2) { FactoryGirl.create(:tagging, :repo_user => user2_repo_user2, :tag => tag1) }

    context "when given tag_ids is blank" do
      it "returns an empty array" do
        expect(RepoSearch.all_by_tag_ids([])).to eq([])
      end

      it "returns a paginateable empty array" do
        results = RepoSearch.all_by_tag_ids([])
        expect(results).to respond_to(:current_page)
      end
    end

    context "when tag_ids is present" do
      it "returns repos that contain ALL the given tags" do
        tag_ids = [tag1, tag2].map(&:id)

        results = RepoSearch.all_by_tag_ids(tag_ids).map(&:id)
        expect(results).to eq([repo2, repo1].map(&:id))
      end

      it "returns only unique repos" do
        tag_ids = [tag2].map(&:id)

        results = RepoSearch.all_by_tag_ids(tag_ids).map(&:id)
        expect(results).to eq([repo2, repo1].map(&:id))
      end

      context "when given tag_ids contain invalid ids" do
        context "when all are invalid" do
          it "returns an empty result set" do
            tag_ids = ["foo", "bar"]
            expect(RepoSearch.all_by_tag_ids(tag_ids)).to eq([])
          end
        end

        context "when some are invalid" do
          it "returns repos that match the valid tags" do
            tag_ids = ["foo", tag2.id, "bar"]

            results = RepoSearch.all_by_tag_ids(tag_ids).map(&:id)
            expect(results).to eq([repo2, repo1].map(&:id))
          end
        end
      end
    end
  end

end
