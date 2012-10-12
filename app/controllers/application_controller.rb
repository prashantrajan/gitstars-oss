class ApplicationController < ActionController::Base
  protect_from_forgery

  # overridden from Devise::Controllers::Helpers
  def after_sign_in_path_for(resource)
    stored_location_for(resource) ||
      if resource.is_a?(User)
        user_url(resource)
      else
        super
      end
  end

  def logical_action_name
    @logical_action_name ||=
      case action_name
        when 'create'
          'new'
        when 'update'
          'edit'
        else
          action_name
    end
  end
  helper_method :logical_action_name

  def body_class
    @body_class ||= "#{controller_name} #{logical_action_name}"
  end
  helper_method :body_class

  def controller_name_for_js
    @controller_name_for_js ||= controller_path.gsub('/', '.')
  end
  helper_method :controller_name_for_js

  def action_name_for_js
    @action_name_for_js ||= logical_action_name
  end
  helper_method :action_name_for_js

  def current_user_is_owner?(user)
    !!(current_user && current_user == user)
  end
  helper_method :current_user_is_owner?

end
