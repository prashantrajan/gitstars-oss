module ApplicationHelper

  def link_to_github_signin(options = {})
    defaults = {'title' => 'Sign in to start managing your starred GitHub repos'}
    options = options.stringify_keys

    link_to(user_omniauth_authorize_path(:github), defaults.merge(options)) do
      yield
    end
  end

  def activate_tab(tab, current_tab)
    tab == current_tab ? 'active' : nil
  end

  def page_title(str)
    content_for(:page_title) { str.to_s }
  end

  def page_meta_title(str)
    content_for(:page_meta_title) { str.to_s }
  end

  def page_meta_description(str)
    content_for(:page_meta_description) { str.to_s }
  end

  def meta_tags
    content_for(:meta_tags) do
      yield
    end
  end

  def meta_tag_for_keywords(str)
    tag(:meta, :name => 'keywords', :content => str)
  end

  def repos_widget?(widget_name)
    widget_name.to_s.downcase == 'repositories'
  end

  def tags_widget?(widget_name)
    widget_name.to_s.downcase == 'tags'
  end

  def render_nav_search?
    !(body_class == 'search index' || body_class == 'home index')
  end

end
