require 'spec_helper'

describe Tag do

  describe "associations" do
    it { should have_many(:taggings).dependent(:destroy) }
    it { should have_many(:repo_users).through(:taggings) }
  end

  describe "validations" do
    before(:each) do
      FactoryGirl.create(:tag, :name => 'foo', :slug => 'foo')
    end

    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name) }

    it { should validate_presence_of(:slug) }
    it { should validate_uniqueness_of(:slug) }

    context "#name" do
      it "allows words in both lowercase, uppercase and combination of both" do
        expect(Tag.new(:name => 'FOOBARX')).to be_valid
        expect(Tag.new(:name => 'foobarx')).to be_valid
        expect(Tag.new(:name => 'Foobarx')).to be_valid
      end

      it "allows spaces in words" do
        expect(Tag.new(:name => 'Foo Bar X')).to be_valid
      end

      it "allows numbers" do
        expect(Tag.new(:name => '69')).to be_valid
      end

      it "allows '-', '.', '_', '+', '#', '&' characters" do
        expect(Tag.new(:name => 'email_processing')).to be_valid
        expect(Tag.new(:name => 'email-processing')).to be_valid
        expect(Tag.new(:name => 'email.processing')).to be_valid
        expect(Tag.new(:name => 'e-mail__process.ing')).to be_valid
        expect(Tag.new(:name => 'C#')).to be_valid
        expect(Tag.new(:name => 'C++')).to be_valid
        expect(Tag.new(:name => 'D&E')).to be_valid
      end

      it "does not allow any other character" do
        ['~', '`', '!', '@', '$', '%', '^', '*', '(', ')', '='].each do |bad_char|
          expect(Tag.new(:name => "email#{bad_char}processing")).to_not be_valid
        end
      end
    end
  end

  describe "before_validation" do
    describe "#sanitize_name" do
      it "strips out whitespace when saving" do
        tag = Tag.new(:name => '  Foo X   Bar ')
        tag.save
        expect(tag.name).to eq('Foo X Bar')
      end
    end
  end


  describe ".by_token" do
    def new_token_hash(token)
      {:id => "<<<#{token}>>>", :name => "New: #{token}"}
    end

    before(:each) do
      Tag.create(:name => 'Hello World')
      Tag.create(:name => 'foobaz')
    end

    context "when given token has an exact match to a db record" do
      it "returns the exact matched results" do
        token = 'foobaz'
        expect(Tag.by_token(token)).to eq(Tag.where("name ILIKE ?", "#{token}%").order(:name).limit(AppSettings.tag_autocomplete_results_limit))
      end
    end

  context "when given token has close matches to db records" do
      it "returns the results with an option for creating a new tag" do
        token = 'foo'
        expected = Tag.where("name ILIKE ?", "#{token}%").order(:name).append(new_token_hash(token))
        expect(Tag.by_token(token)).to eq(expected)
      end
    end

    context "when given token does not match any db record" do
      it "returns results containing option for creating a new tag" do
        token = 'mrp'
        expect(Tag.by_token(token)).to eq([new_token_hash(token)])
      end
    end
  end

  describe ".ids_from_tokens" do
    let!(:tag1) { Tag.create(:name => 'Hello World') }
    let!(:tag2) { Tag.create(:name => 'foobaz') }
    let!(:tag3) { Tag.create(:name => 'ruby') }

    let(:tokens) { Tag.pluck(:id).join(',') }

    context "when all given tokens are ids" do
      it "returns an array of tag ids" do
        expect(Tag.ids_from_tokens(tokens)).to eq(tokens.split(','))
      end

      it "returns only unique ids" do
        expect(Tag.ids_from_tokens("#{tokens},#{tokens}")).to eq(tokens.split(','))
      end
    end

    context "when given tokens contain <<<possibly new token tags>>>" do
      let!(:existing_tag) { Tag.create(:name => 'new_for_this_user') }
      let(:new_tag_tokens) { "#{tokens},<<<first_new_tag>>>,<<<#{existing_tag.name.upcase}>>>,<<<second new tag>>>" }

      it "creates the new tags ignoring any existing tags" do
        expect {
          Tag.ids_from_tokens(new_tag_tokens)
        }.to change{ Tag.count }.by(2)
      end

      it "returns only unique ids" do
        expect(Tag.ids_from_tokens(new_tag_tokens)).to eq(new_tag_tokens.split(',').uniq)
      end
    end
  end

  describe ".site_wide" do
    it "returns an ActiveRecord::Relation" do
      expect(Tag.site_wide).to be_an_instance_of(ActiveRecord::Relation)
    end
  end

 describe ".popular_site_wide" do
    it "returns an ActiveRecord::Relation" do
      expect(Tag.popular_site_wide).to be_an_instance_of(ActiveRecord::Relation)
    end
  end

  describe ".popular_for_user" do
    let!(:user) { FactoryGirl.create(:user) }

    it "returns an ActiveRecord::Relation" do
      expect(Tag.popular_for_user(user)).to be_an_instance_of(ActiveRecord::Relation)
    end
  end

  describe ".recommended_list_for_repo" do
    let!(:user1) { FactoryGirl.create(:user) }
    let!(:user2) { FactoryGirl.create(:user) }
    let!(:repo_user1) { FactoryGirl.create(:repo_user, :user => user1, :repo => repo) }
    let!(:repo_user2) { FactoryGirl.create(:repo_user, :user => user2, :repo => repo) }
    let!(:tag1) { FactoryGirl.create(:tag, :name => 'T1') }
    let!(:tag2) { FactoryGirl.create(:tag, :name => 'T2') }

    before(:each) do
      FactoryGirl.create(:tagging, :repo_user => repo_user1, :tag => tag1)
      FactoryGirl.create(:tagging, :repo_user => repo_user1, :tag => tag2)
      FactoryGirl.create(:tagging, :repo_user => repo_user2, :tag => tag1)
    end

    context "when repo has a primary language" do
      let!(:repo) { FactoryGirl.create(:repo, :primary_language => 'Ruby') }

      it "returns an array of tag names based on popular usage with the primary language as the first element" do
        tag_list = Tag.recommended_list_for_repo(repo)
        expect(tag_list).to eq([repo.primary_language, tag1.name, tag2.name])
      end
    end

    context "when repo does not have a primary language" do
      let!(:repo) { FactoryGirl.create(:repo, :primary_language => nil) }

      it "returns an array of tag names based on popular usage" do
        tag_list = Tag.recommended_list_for_repo(repo)
        expect(tag_list).to eq([tag1.name, tag2.name])
      end
    end
  end

  describe "#slug db attribute" do
    it "saves a slug version of the name" do
      tag = Tag.create(:name => 'Foo Bar')

      expect(tag).to be_valid
      expect(tag.slug).to eq(tag.name.parameterize)
    end
  end

  describe "#to_param" do
    it "returns the slug" do
      tag = FactoryGirl.create(:tag)
      expect(tag.to_param).to eq(tag.slug)
    end
  end

end
