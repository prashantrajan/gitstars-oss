require 'spec_helper'

describe ApplicationHelper do

  describe "#repos_widget?" do
    context "given widget name is 'Repositories'" do
      it "returns true" do
        expect(helper.repos_widget?('Repositories')).to be_true
      end
    end

    context "given widget name is not 'Repos'" do
      it "returns false" do
        expect(helper.repos_widget?('T')).to be_false
      end
    end
  end

  describe "#tags_widget?" do
    context "given widget name is 'Tags'" do
      it "returns true" do
        expect(helper.tags_widget?('Tags')).to be_true
      end
    end

    context "given widget name is not 'Tags'" do
      it "returns false" do
        expect(helper.tags_widget?('R')).to be_false
      end
    end
  end

  describe "#render_nav_search?" do
    context "when view is search/index" do
      it "returns false" do
        helper.stub(:body_class).and_return('search index')
        expect(helper.render_nav_search?).to be_false
      end
    end

    context "when view is home/index" do
      it "returns false" do
        helper.stub(:body_class).and_return('home index')
        expect(helper.render_nav_search?).to be_false
      end
    end

    context "when view anything other than search/index or home/index" do
      it "returns false" do
        helper.stub(:body_class).and_return('tags index')
        expect(helper.render_nav_search?).to be_true
      end
    end
  end

end
