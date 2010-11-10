class SessionsController < ApplicationController
  def create
    rack_auth = request.env['rack.auth']
    @auth = Authorization.find_by_provider_and_uid(rack_auth['provider'], rack_auth['uid'])
    if @auth.nil?
      user = User.find_or_create_by_name(rack_auth['user_info']['name'])
      @auth = Authorization.create(:user => user, :uid => rack_auth['uid'], :provider => rack_auth['provider'])
    end
    self.current_user = @auth.user
    flash.notice = "Welcome, #{current_user.name}"
    redirect_to root_url
  end

  def destroy
    self.current_user = nil
    flash.notice = "Logged out"
    redirect_to root_url
  end

  def failure
    self.current_user = nil
    flash.alert = auth_failure_message
    redirect_to root_url
  end

  private

  def auth_failure_message
    case params[:message]
    when 'invalid_credentials'
      'Invalid credentials'
    else
      'Sign in failed'
    end
  end
end
