class SessionsController < ApplicationController
  def create
    rack_auth = request.env['rack.auth']
    @auth = Authorization.find_from_hash(rack_auth)
    if @auth.nil?
      @auth = Authorization.create_from_hash(rack_auth, current_user)
    end
    self.current_user = @auth.user
    flash.notice = "Welcome, #{current_user.name}."
    redirect_to root_url
  end

  def destroy
    self.current_user = nil
    flash.notice = "Logged out."
    redirect_to root_url
  end
end
