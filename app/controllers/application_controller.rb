class ApplicationController < ActionController::Base
  protect_from_forgery

  protected

  def current_user
    if Rails.env == 'development'
      user = User.find_by_id(1)
      user ||= User.new(:nickname => 'Developer')
      user.id = 1
      user.save!
      session[:user_id] = 1
    end
    @current_user ||= User.find_by_id(session[:user_id])
  end

  def signed_in?
    current_user.present? and not current_user.new_record?
  end

  helper_method :current_user, :signed_in?

  def current_user=(user)
    @current_user = user
    session[:user_id] = user.try(:id)
  end
end
