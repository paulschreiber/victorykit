require 'whiplash'
class ApplicationController < ActionController::Base
  include Bandit
  helper_method :win!, :spin!
  
  protect_from_forgery
  before_filter :add_environment_to_title
  before_filter :set_host_for_urls

  def add_environment_to_title
    @title = "VictoryKit"
    @title << " - #{Rails.env}" unless Rails.env.production? 
  end

  def set_host_for_urls
    ActionMailer::Base.default_url_options = { host: request.host_with_port }
  end
  
  private
  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end
  helper_method :current_user
    
  def authorize
    redirect_to login_path if current_user.nil?
  end
    
  def authorize_super_user
    if current_user.nil?
      redirect_to login_path 
    elsif !(current_user.is_super_user || current_user.is_admin)
      render_403
    end
  end
  
  def render_403
    render :text => "You are not authorized to view this page", :status => 403
  end
end
