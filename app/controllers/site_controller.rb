class SiteController < ApplicationController

  before_filter :require_facebook_install
  before_filter :require_facebook_login
  before_filter :must_be_developer, :only => [:dev_current_games, :dev_finished_games]

  def index
    #@current_games = Game.active.played_by(fb_user_id).paginate(:page => params[:cur_page], :per_page => 10, :count => {:select => 'DISTINCT games.id'})
    @open_games = Game.active.open.size
    if @open_games < 30
      @my_available_open_games = Game.active.open.available_to_user(fb_user_id).size + 1
      @my_available_open_draw_games = Game.active.open.draw_phase.available_to_user(fb_user_id).size + 1
    else 
      @my_available_open_games = Game.active.open.available_to_user(fb_user_id).size
      @my_available_open_draw_games = Game.active.open.draw_phase.available_to_user(fb_user_id).size 
    end
    @my_available_open_write_games = Game.active.open.describe_phase.available_to_user(fb_user_id).size


    @my_turn_games = Game.active.is_turn_of(fb_user_id).paginate(:page => params[:my_page], :per_page => 3, :count => {:select => 'DISTINCT games.id'})
    @short_current_games = Game.active.played_by(fb_user_id).not_turn_of(fb_user_id).order_by('updated').paginate(:page => params[:cur_page], :per_page => 8, :count => {:select => 'DISTINCT games.id'})
    @short_finished_games = Game.finished.played_by(fb_user_id).order_by('finished').paginate(:page => params[:fin_page], :per_page => 4, :count => {:select => 'DISTINCT games.id'})

    examples_glob = File.join(RAILS_ROOT, 'public', 'examples', '*.png')
    @example_drawing_url_paths = Dir.glob(examples_glob).map{|fn| "/examples/#{File.basename(fn)}" }
    @example_drawing_url_paths = @example_drawing_url_paths.sort_by{ rand }[0, 4]
  end

  def draw
    if @game = Game.active.open.draw_phase.available_to_user(fb_user_id).order_by_oldest.first
      @game.assign_player!(fb_user_id)
      redirect_to(game_path(@game))
    else
      redirect_to(new_open_game_path)
    end
  end

  def write
    @game = Game.active.open.describe_phase.available_to_user(fb_user_id).order_by_oldest.first
    @game.assign_player!(fb_user_id)
    redirect_to(game_path(@game))
  end

  def current_games
    @current_games = Game.active.played_by(fb_user_id).order_by('updated').paginate(:page => params[:cur_page], :per_page => 30, :count => {:select => 'DISTINCT games.id'})
  end

  def finished_games
    games = Game.finished.played_by(fb_user_id).order_by(params[:order] || 'finished')
    @finished_games = games.paginate(:page => params[:fin_page], :per_page => 10, :count => {:select => 'DISTINCT games.id'})
    render :action => :finished_games
  end

  def dev_current_games
    @dev_current_games = Game.active.order_by('updated').paginate(:page => params[:cur_page], :per_page => 50 )
  end

  def dev_finished_games
    games = Game.order_by(params[:order] || 'finished').finished
    @dev_finished_games = games.paginate(:page => params[:fin_page], :per_page => 50 )
    render :action => :dev_finished_games
  end

  def old_index
    redirect_to games_path, :status => 301 
  end

  def adsense
    render :action => :adsense, :layout => "iframe_layout"
  end

  def welcome
    # Welcome web page that users are redirected after adding the app.
    @friends_with_app = get_friends_with_app
  end

=begin
# this all needs to be done in a user model.
# Need to create a user model, when a new user is created then we will call this method.
  def notify_app_user_friends
    message = " just added Piccon! Why not welcome <fb:pronoun uid=\"#{fbsession.session_user_id}\" useyou=\"false\" capitalize=\"false\" /> by starting a <a href=\"#{APP_URL}/game/new/\">new game</a> with <fb:pronoun uid=\"#{fbsession.session_user_id}\" useyou=\"false\" capitalize=\"false\" />?"
    if @friends_with_app.any?
      begin
        logger.debug "Sending notification to new Piccon user's friends that they have joined Piccon."
        fbsession.notifications_send(:to_ids => @friends_with_app, :notification => message) 
      rescue
        add_warning "Unable to notify the new Piccon user's friends that they have joined Piccon."
      end
    end
  end
=end

  def invite
    @friends_with_app = get_friends_with_app
  end

  def invited
    redirect_to games_path
  end

end
