class UsersController < ApplicationController

  def show
    load_user
    load_repos
    load_popular_tags
    @pending_repos_fetch = current_user_is_owner?(@user) && @user.pending_first_github_repos_fetch?
  end

  def latest_repos
    return unless request.xhr?
    load_user

    if @user.pending_github_repos_fetch?
      render :text => 'pending'
    else
      load_repos
      load_popular_tags

      widget_content = render_to_string(:partial => 'repos/list', :locals => {:repos => @repos, :page_owner => @user}).html_safe
      render(:partial => 'users/tab', :locals => {
              :user => @user, :widget_name => t(:repositories), :widget_content => widget_content, :tags => @popular_tags, :repos => @repos })
    end
  end


  private

  def load_user
    @user = User.find_by_login!(params[:id].downcase)
  end

  def load_popular_tags
    @popular_tags = Tag.popular_for_user(@user).limit(9)
  end

  def load_repos
    @repos = RepoUser.includes([:taggings]).where(:repo_users => {:user_id => @user.id}).includes(:repo, :tags).order('repo_users.created_at DESC').page(params[:page])
  end

end
