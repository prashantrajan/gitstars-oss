class OmniauthCallbacksController < Devise::OmniauthCallbacksController

  def github
    #raise request.env['omniauth.auth'].to_yaml

    user = User.from_github_omniauth(request.env['omniauth.auth'])
    if user.persisted?
      flash.notice = t('devise.sessions.signed_in')
      sign_in_and_redirect(:user, user)
    end
  end

end
