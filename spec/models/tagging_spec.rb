require 'spec_helper'

describe Tagging do

  describe "associations" do
    it { should belong_to(:tag) }
    it { should belong_to(:repo_user) }
  end

  describe "validations" do
    before(:each) do
      FactoryGirl.create(:tagging)
    end

    it { should validate_uniqueness_of(:repo_user_id).scoped_to(:tag_id) }
  end

end
