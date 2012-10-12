module OmniauthResponseHelpers

  def github_successful_auth_response(options = {})
    OmniAuth::AuthHash.new({
      :provider => 'github',
      :uid => '2108436',
      :info => {
        :nickname => 'gitstars',
        :email => nil,
        :name => nil,
        :image => 'https://secure.gravatar.com/avatar/6622578838eea6f1c10227287ffb8f59?d=https://a248.e.akamai.net/assets.github.com%2Fimages%2Fgravatars%2Fgravatar-140.png'
      },
      :credentials => {
        :token => '50e0e4dd43280a3a12315120757e6ee32b61cc9a',
        :expires => false
      },
      :extra => {
        :raw_info => {
          :bio => "Helpful, sometimes.Left-handed always.",
          :created_at => '2012-08-07T07:27:41Z',
          :company => 'Totally Awesome Inc.',
          :blog => 'http://www.johndoe.com',
          :location => 'Singapore',
          :avatar_url => 'https://secure.gravatar.com/avatar/6622578838eea6f1c10227287ffb8f59?d=https://a248.e.akamai.net/assets.github.com%2Fimages%2Fgravatars%2Fgravatar-140.png',
          :html_url => 'https://github.com/gitstars',
          :hireable => false,
          :login => 'gitstars',
          :id => 2108436
        }
      }
    })
  end

end
