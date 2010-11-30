class SessionsController < ApplicationController
  def create
    rack_auth = request.env['rack.auth']
    case rack_auth['provider']
    when 'facebook'
      user = self.current_user || User.find_by_fb_id(rack_auth['uid'])
      user.name ||= rack_auth['user_info']['name']
      user.fb_id ||= rack_auth['uid']
      user.fb_auth = true
      if user.save
        self.current_user = user
        flash.notice = "Welcome, #{current_user.name}"
        redirect_to root_url
      else
        self.current_user = nil
        flash.alert = user.errors.full_messages
        redirect_to root_url
      end
    end
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
