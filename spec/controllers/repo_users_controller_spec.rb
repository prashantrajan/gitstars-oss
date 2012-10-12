require 'spec_helper'

describe RepoUsersController do

  describe "PUT update" do
    let!(:user) { FactoryGirl.create(:user) }
    let!(:repo_user) { FactoryGirl.create(:repo_user, :user => user) }

    before(:each) do
      sign_in user
    end

    def do_request(params = {}, options = {:xhr => false})
      params = {:id => repo_user.id, :repo_user => {:tag_tokens => "<<<newtag1>>>,<<<newtag2>>>"}}.merge(params)
      if options[:xhr]
        xhr :put, :update, params
      else
        put :update, params
      end

      repo_user.reload
    end

    it_behaves_like "requires user sign in"

    context "security" do
      context "current_user does not own the repo_user resource" do
        it "raises an error" do
          malicious_user = FactoryGirl.create(:user)
          sign_in malicious_user

          expect {
            do_request({}, :xhr => true)
          }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end

    context "with valid params" do
      it "updates the repo_user resource with the given tags" do
        expect {
          do_request({}, :xhr => true)
        }.to change{ repo_user.tag_ids }
      end

      it "renders the repos/tag_form partial" do
        do_request({}, :xhr => true)

        expect(response).to be_success
        expect(response).to render_template('repos/_tag_form')
      end
    end
  end

end
