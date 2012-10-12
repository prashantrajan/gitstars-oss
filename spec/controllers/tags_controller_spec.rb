require 'spec_helper'

describe TagsController do

  describe "GET index" do
    let!(:user) { FactoryGirl.create(:user) }

    def do_request
      get :index, :user_id => user.to_param
    end

    before(:each) do
      do_request
    end

    it "assigns @tags with the user's tags" do
      expect(assigns(:tags)).to be
    end

    it "assigns @user" do
      expect(assigns(:user)).to eq(user)
    end

    it "renders the index template" do
      expect(response).to render_template(:index)
    end
  end

  describe "GET names" do
    let!(:user) { FactoryGirl.create(:user) }

    before(:each) do
      sign_in user
    end

    def do_request(params = {})
      get :names, {:user_id => user.to_param, :q => 'tag'}.merge(params)
    end

    it_behaves_like "requires user sign in"

    it "assigns @tags with matched tags from the user's tag list" do
      do_request
      expect(assigns(:tags)).to be
    end

    it "supports returning a JSON response" do
      do_request(:format => :json)
      expect(response.body).to eq(assigns(:tags).to_json)
    end
  end

  describe "GET all_names" do
    def do_request(params = {})
      get :all_names, {:q => 'tag'}.merge(params)
    end

    it "assigns @tags with matched tags from the user's tag list" do
      do_request
      expect(assigns(:tags)).to be
    end

    it "supports returning a JSON response" do
      do_request(:format => :json)
      expect(response.body).to eq(assigns(:tags).to_json)
    end
  end

  describe "GET show" do
    let!(:tag) { FactoryGirl.create(:tag) }

    def do_request(params = {})
      get :show, {:id => tag.to_param}.merge(params)
    end

    context "when :user_id is not present" do
      before(:each) do
        do_request
      end

      it "assigns @tag" do
        expect(assigns(:tag)).to eq(tag)
      end

      it "assigns @repos" do
        expect(assigns(:repos)).to be
      end

      it "renders the show template" do
        expect(response).to render_template(:show)
      end
    end

    context "when :user_ud is present" do
      let!(:user) { FactoryGirl.create(:user) }

      before(:each) do
        do_request(:user_id => user.to_param)
      end

      it "assigns @tag" do
        expect(assigns(:tag)).to eq(tag)
      end

      it "assigns @user" do
        expect(assigns(:user)).to eq(user)
      end

      it "assigns @repos" do
        expect(assigns(:repos)).to be
      end

      it "renders the show template" do
        expect(response).to render_template(:show)
      end
    end
  end

end
