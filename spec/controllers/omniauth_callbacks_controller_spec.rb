require 'spec_helper'

describe OmniauthCallbacksController do
  before(:each) do
    request.env['devise.mapping'] = Devise.mappings[:user]
  end

  describe "#github" do
    def do_request
      get :github
    end

    context "with valid params" do
      let(:auth) { github_successful_auth_response }

      before(:each) do
        OmniAuth.config.mock_auth[:github] = auth
        request.env['omniauth.auth'] = OmniAuth.config.mock_auth[:github]
      end

      context "new user" do
        it "creates a new user record" do
          expect {
            do_request
          }.to change { User.count }.by(1)
        end

        it "signs in the user" do
          do_request
          expect(warden.authenticated?(:user)).to be_true
        end

        it "redirects to the user show url" do
          do_request
          expect(flash.notice).to be_present
          expect(response).to redirect_to(user_url(User.last))
        end
      end

      context "existing user" do
        let!(:user) { FactoryGirl.create(:real_github_user) }

        it "does not create a new user record" do
          expect {
            do_request
          }.to_not change { User.count }
        end

        it "signs in the user" do
          do_request
          expect(warden.authenticated?(:user)).to be_true
        end

        it "redirects to the user show url" do
          do_request
          expect(flash.notice).to be_present
          expect(response).to redirect_to(user_url(user))
        end
      end
    end
  end

end
