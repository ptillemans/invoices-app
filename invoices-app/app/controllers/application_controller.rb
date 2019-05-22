require 'pp'

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery
  helper_method :current_user

  def current_user
    if Rails.env.melexis?
      username = session['cas']['user']
      attributes = session['cas']['extra_attributes']
      puts "Attributes: "
      pp(session['cas']);
      User.find_or_create_by(username: username, password: "***")
    else Rails.env.fremach?
      username = session['user']
    end
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, :alert => exception.message
  end

  before_filter do
    resource = controller_name.singularize.to_sym
    method = "#{resource}_params"
    params[resource] &&= send(method) if respond_to?(method, true)
  end

end
