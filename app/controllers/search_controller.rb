class SearchController < ApplicationController

  def index
    tag_ids = params[:q].to_s.split(',')
    @searched_tags = Tag.where(:id => tag_ids)
    @repos = RepoSearch.all_by_tag_ids(tag_ids, :page => params[:page])
  end

end
