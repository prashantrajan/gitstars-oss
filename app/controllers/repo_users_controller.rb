class RepoUsersController < ApplicationController
  before_filter :authenticate_user!

  def update
    @repo_user = current_user.repo_users.find(params[:id])

    if @repo_user.update_attributes(repo_user_params)
      render :partial => 'repos/tag_form', :locals => {
        :page_owner => current_user, :repo => @repo_user.repo, :repo_user => @repo_user, :tags => @repo_user.tags
      }
    else
      render :text => 'Failed to update repo_user with tags'
    end
  end


  private

  def repo_user_params
    params.require(:repo_user).permit(:tag_tokens)
  end

end
