class HomeController < ApplicationController

  def index
    @tags = Tag.popular_site_wide.limit(60)
    @recent_users = User.recent.limit(12)
  end

end
