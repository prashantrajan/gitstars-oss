require 'spec_helper'

describe ApplicationController do

  controller do
    layout 'application'

    def index
      render :text => 'an anonymous action', :layout => true
    end
  end


  describe "#after_sign_in_path_for" do
    context "given resource is a User object" do
      it "returns the user url" do
        user = FactoryGirl.create(:user)
        expect(controller.after_sign_in_path_for(user)).to eq(user_url(user))
      end
    end
  end

  describe "#current_user_is_owner?" do
    let(:owner_user) { FactoryGirl.create(:user) }

    context "no current_user" do
      it "returns false" do
        get :index
        expect(controller.current_user_is_owner?(owner_user)).to eq(false)
        expect(controller.current_user_is_owner?(nil)).to eq(false)
      end
    end

    context "current user is not the page owner" do
      it "returns false" do
        another_user = FactoryGirl.create(:user)
        sign_in another_user
        expect(controller.current_user_is_owner?(owner_user)).to be_false
      end
    end

    context "current user is the page owner" do
      it "returns false" do
        sign_in owner_user
        expect(controller.current_user_is_owner?(owner_user)).to be_true
      end
    end
  end

end
