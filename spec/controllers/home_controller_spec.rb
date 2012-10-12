require 'spec_helper'

describe HomeController do

  describe "GET index" do
    def do_request
      get :index
    end

    it "assigns @tags with tags that are currently being used site wide" do
      do_request
      expect(assigns(:tags)).to be
    end

    it "assigns @tags with tags that are currently being used site wide" do
      do_request
      expect(assigns(:recent_users)).to be
    end

    it "renders the index template" do
      do_request
      expect(response).to render_template('index')
    end
  end

end
