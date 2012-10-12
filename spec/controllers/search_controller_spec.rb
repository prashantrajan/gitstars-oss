require 'spec_helper'

describe SearchController do

  describe "GET index" do
    let!(:tag1) { FactoryGirl.create(:tag) }
    let!(:tag2) { FactoryGirl.create(:tag) }

    let(:q) { "#{tag1.id},#{tag2.id}" }

    def do_request(params = {})
      get :index, {:q => q}.merge(params)
    end

    it "assigns @searched_tags with the searched tags" do
      do_request
      expect(assigns(:searched_tags)).to match_array([tag1, tag2])
    end

    it "assigns @repos with the matching repos" do
      do_request
      expect(assigns(:repos)).to be
    end

    it "renders the index template" do
      do_request
      expect(response).to render_template(:index)
    end
  end

end
