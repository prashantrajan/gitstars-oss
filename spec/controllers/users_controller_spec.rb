require 'spec_helper'

describe UsersController do

  describe "GET index" do
    let!(:user) { FactoryGirl.create(:user) }

    def do_request
      get :show, :id => user.to_param
    end

    it "assigns @user with the page owner" do
      do_request
      expect(assigns(:user)).to eq(user)
    end

    it "assigns @repos with the repos belonging to the page owner" do
      do_request
      expect(assigns(:repos)).to be
    end

    it "assigns @popular_tags" do
      do_request
      expect(assigns(:popular_tags)).to be
    end

    it "assigns @pending_repos_fetch" do
      do_request
      expect(assigns(:pending_repos_fetch)).to eq(false)
    end

    it "renders the show template" do
      do_request
      expect(response).to render_template('show')
    end
  end

  describe "GET latest_repos" do
    let!(:user) { FactoryGirl.create(:user) }

    def do_request
      xhr :get, :latest_repos, :id => user.to_param
    end

    context "user's pending_github_repos_fetch? is true" do
      before(:each) do
        User.any_instance.stub(:pending_github_repos_fetch?).and_return(true)
      end

      it "returns a response with text 'pending'" do
        do_request
        expect(response.body).to eq("pending")
      end
    end

    context "user's pending_github_repos_fetch? is false" do
      before(:each) do
        User.any_instance.stub(:pending_github_repos_fetch?).and_return(false)
      end

      it "assigns @user with the page owner" do
        do_request
        expect(assigns(:user)).to eq(user)
      end

      it "assigns @repos with the repos belonging to the page owner" do
        do_request
        expect(assigns(:repos)).to be
      end

      it "assigns @popular_tags" do
        do_request
        expect(assigns(:popular_tags)).to be
      end

      it "renders the the users/tab partial" do
        do_request
        expect(response).to render_template('users/_tab')
      end
    end
  end

end
