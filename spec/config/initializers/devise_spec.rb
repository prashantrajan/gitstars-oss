require 'spec_helper'

describe 'Devise config' do

  describe "OmniAuth" do
    context "GitHub" do
      it "sets the consumer key & secret" do
        consumer_key, consumer_secret = Devise.omniauth_configs[:github].args

        expect(consumer_key).to_not be_blank
        expect(consumer_key).to eq(AppSettings.github.client_id)

        expect(consumer_secret).to_not be_blank
        expect(consumer_secret).to eq(AppSettings.github.client_secret)
      end
    end
  end

end
