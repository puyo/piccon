class Post < ActiveRecord::Base
  belongs_to :game

  def author
    Player.find(:first, :conditions => ['game_id = ? AND user_id = ?', game.id, author_id])
  end

  validates_presence_of :game
  validates_presence_of :author_id
  validate :check_is_right_phase

  attr_writer :image
  attr_accessor :fbsession # set in controller, used in model to send notifications

  before_create :save_image_if_drawing
  after_create :finish_game_if_necessary
  after_create :update_game_turn
  after_create :update_facebook

  named_scope :by, lambda{|author_id| 
    { :conditions => ['author_id = ?', author_id] }
  }
  named_scope :descriptions, :conditions => ['text IS NOT NULL']
  named_scope :drawings, :conditions => ['image_filename IS NOT NULL']

  def warnings
    @warnings ||= Array.new()
  end

  def is_drawing?
    not (@image.nil? and image_filename.nil?)
  end

  def is_description?
    not text.nil?
  end

  def image_disk_path
    File.join(RAILS_ROOT, 'public', 'drawings', image_filename)
  end

  def image_url_path
    File.join('/drawings', image_filename)
  end

  def update_facebook
    if fbsession
      if game.posts.empty? # no other posts yet
        publish_feed_story_new_game
        if !game.owner.nil? # if it is not an open game
          notify_next_player
        end
      elsif game.is_finished?
        notify_everyone_game_ended
        publish_feed_story_game_ended 
      else
        #publish_feed_story_round_played # TODO: think about it
        if !game.owner.nil? # if it is not an open game
          notify_next_player
        end
      end
    else
      logger.warn("Could not update Facebook, did not have access to a Facebook session")
    end
  end

  def notify_everyone_game_ended
    message = " just finished a game of Piccon you were playing. <a href=\"#{play_url}\">View the result</a>."
    to_ids = game.players.active.except(fbsession.session_user_id).map{|p| p.user_id }
    if to_ids.any?
      begin
        logger.debug "Sending notification to other players of game #{game.id}: #{message}"
        fbsession.notifications_send(:to_ids => to_ids, :notification => message) 
      rescue Exception => e
        add_warning "Unable to notify players that the game ended: #{e}"
      end
    end
  end

  def publish_feed_story_new_game
    title_text = " just started a game of <a href=\"#{APP_URL}/\">Piccon</a>."
    names = game.invited_players.map{|player| "<fb:name ifcantsee=\"someone\" uid=\"#{player.user_id}\"/>" }
    if names.any?
      message = "<fb:pronoun uid=\"#{game.owner.user_id}\" useyou=\"false\" capitalize=\"true\" /> invited #{conjunction(names)} to play a <a href=\"#{play_url}\">game</a> of Piccon."
    else
      message = ""
    end
    message << " <a href=\"#{APP_URL}/\">Start your own game of Piccon!</a>"
    begin
      fbsession.feed_publishActionOfUser(:title => title_text, :body => message) 
    rescue Exception => e
      add_warning "Unable to publish to feed: #{e}"
    end
  end

  def publish_feed_story_game_ended
  end

  def play_url
    "#{APP_URL}/game/view/#{game.id}"
  end

  def leave_url
    "#{APP_URL}/game/leave/#{game.id}"
  end

  def next_player_user_id
    game.current_turn_player.user_id
  end

  def notify_next_player
    message = " just played <fb:pronoun uid=\"#{fbsession.session_user_id}\" useyou=\"false\" possessive=\"true\" /> turn"
    if game.posts.by(next_player_user_id).empty? # is new to this game
      player_ids = game.players.map{|player| player.user_id }
      player_ids.delete(next_player_user_id)
      player_ids.delete(fbsession.session_user_id)
      names = player_ids.map{|id| "<fb:name ifcantsee=\"someone\" uid=\"#{id}\"/>" }
      names << "you"
      message << " in a game of Piccon with #{conjunction(names)}." <<
        " Come and <a href=\"#{play_url}\">play</a>!"
    else
      message << "." <<
        " <a href=\"#{play_url}\">Play your turn</a>" << 
        ", <a href=\"#{leave_url}\">Quit this game</a>"
    end
    logger.debug "Sending notification: #{message}"
    begin
      fbsession.notifications_send(:to_ids => [next_player_user_id], :notification => message) 
    rescue Exception => e
      add_warning "Unable to notify next player to take their turn: #{e}"
    end
  end

  private

  def add_warning(warning)
    logger.warn warning
    warnings << warning
  end

  def conjunction(list)
    list = list.dup # because we destroy it
    last = list.pop
    if list.any?
      [list.join(', '), last].join(' and ')
    else
      last
    end
  end

  def finish_game_if_necessary
    if game.posts.size >= game.length # this post has been inserted
      game.fbsession = fbsession
      game.finish!
    end
  end

  def save_image_if_drawing
    if @image
      self.image_filename = "#{@game.id}-#{@game.posts.size}.png"

      if RAILS_ENV != 'test'
        File.open(image_disk_path, 'wb') do |f|
        f.print @image.string
        end
      end
      @image = nil
    end
  end

  def check_is_right_phase
    if is_drawing? and not @game.is_draw_phase?
      errors.add_to_base("This game is not in the draw phase")
    end
    if is_description? and not @game.is_describe_phase?
      errors.add_to_base("This game is not in the describe phase")
    end
  end

  def update_game_turn
    game.turn_complete!
  end

end
