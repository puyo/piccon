# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  #protect_from_forgery # :secret => '17a1f3eacfcedfaf0e5df4458f10d321'

  private

  def adjust_format
    request.format = :fbml if params[:fb_sig]
  end

  layout 'fbml'

  def fb_user_id
    fbsession.session_user_id.to_i
  end

  def is_developer?
    fb_user_id.to_i == 644163622 or fb_user_id.to_i == 642511718
  end

  def get_friends_with_app
    app_users_xml = fbsession.friends_getAppUsers
    uids = (app_users_xml/"uid").map{|u| u.inner_text }
  end

  def get_friends_who_need_invites(player_ids)
    player_ids - get_friends_with_app
  end

  def must_be_developer
    if not is_developer?
      flash[:errors] = ["You are not a game developer"]
      return redirect_to(games_path)
    end
  end

  def rescue_action_with_email(exception)
    begin
      ExceptionNotifier.deliver_exception_notification(exception, self, request, {}) if RAILS_ENV == 'production'
    rescue
      logger.error("Could not send error email")
    end
    rescue_action_without_email(exception)
  end

  alias_method_chain :rescue_action, :email
end

class ActionView::Base
  def stylesheet(filename)
    format("<style>%s</style", File.read(RAILS_ROOT + "/public/stylesheets/#{filename}"))
  end
end
