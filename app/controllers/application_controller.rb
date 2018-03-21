class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :configure_devise_parameters, if: :devise_controller?
  

  def after_sign_in_path_for resource
    profile_index_path
  end

  def call_rake(task, options = {})
    options[:rails_env] ||= Rails.env
    args = options.map { |n, v| "#{n.to_s.upcase}='#{v}'" }
    system "rake #{task} #{args.join(' ')} --trace 2>&1 >> #{Rails.root}/log/rake.log &" # '&' symbol indicates that it will be executed in background
  end


  # def not_found
  #   raise ActionController::RoutingError.new('Not Found')
  # end
  #

  

  private
  def configure_devise_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name,:last_name])
    # devise_parameter_sanitizer.permit(:sign_in, keys: [:username], except: [:email])
  end
  
  
  
end
