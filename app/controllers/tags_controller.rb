class TagsController < ApplicationController
  before_filter :load_user, :only => [:index, :show]
  before_filter :authenticate_user!, :only => [:names]

  def all_names
    @tags = Tag.find_all_by_name_ci("#{params[:q]}%").order(:name).limit(AppSettings.tag_autocomplete_results_limit)

    respond_to do |format|
      format.json { render :json => @tags }
    end
  end

  def show
    slug = params[:id].downcase
    @tag = Tag.find_by_slug!(slug)

    if @user
      # TODO: Tags for the repos are not being loaded from here but via n+1 queries in the view!
      # ... the where clause limits the tags so including :tags here doesn't produce the expected results
      @repos = RepoUser.includes([:taggings]).joins(:tags).where(:repo_users => {:user_id => @user.id}, :tags => {:slug => slug}).includes(:repo).order('repo_users.created_at DESC')
    else
      @repos = @tag.repos.includes(:tags).order('repos.stargazers DESC')
    end

    @repos = @repos.page(params[:page])
  end

  def names
    @tags = current_user.tags.by_token(params[:q])

    respond_to do |format|
      format.json { render :json => @tags }
    end
  end

  def index
    @tags = Tag.popular_for_user(@user)
  end


  private

  def load_user
    if params[:user_id]
      @user = User.find_by_login!(params[:user_id].downcase)
    end
  end

end
