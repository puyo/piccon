def render_text(caption_text, width_constraint, &block)
  Magick::Image.read("caption:#{caption_text.to_s}") {
    # this wraps the text to fixed width
    self.size = width_constraint
    # other optional settings
    block.call(self) if block_given?
  }.first
end

class Game < ActiveRecord::Base
  after_save :notify_new_owner

  STORAGE_DAYS = 14

  has_many :posts
  has_many :users, :through => :players
  has_many :players

  # More of a has_one, but has to be belongs_to because the foreign key is on
  # the games table, not the posts table.
  belongs_to :thumbnail_post, :class_name => 'Post' 

  # More of a has_one, but has to be belongs_to because the foreign key is on
  # the games table, not the posts table.
  belongs_to :featured_thumbnail_post, :class_name => 'Post' 

  NEW = 0
  STARTED = 1
  FINISHED = 2 # private

  PRIVATE_R18 = 20
  PUBLIC = 30
  PUBLIC_R18 = 40
  OFFENSIVE = 50

  DRAW = false
  DESCRIBE = true

  validates_numericality_of :length, :only_integer => true, :greater_than_or_equal_to => 1, :less_than_or_equal_to => 24 
  #validates_numericality_of :owner_id 

  validate do |game|
    if game.status == NEW
      game.errors.add_to_base("Game must be started in order to save it") 
    end
  end

  named_scope :with_posts, :include => 'posts'
  named_scope :with_active_players, :include => 'players', :conditions => ['players.status = ?', Player::ACTIVE]
  named_scope :finished, :conditions => ['games.status >= ?', FINISHED]
  named_scope :active,  :conditions => { :status => STARTED }  
  named_scope :played_by, lambda{|user_id| 
    { :conditions => ['played_by_player.user_id = ? AND played_by_player.status = ?', user_id, Player::ACTIVE], 
      :joins => 'JOIN players AS played_by_player ON (played_by_player.game_id = games.id)', 
      :select => 'DISTINCT games.*' 
    }
  }
  named_scope :is_turn_of, lambda{|user_id| 
    { :order => "games.updated_at ASC" , :conditions => ['current_player_id = ?', user_id ]}
  }
  named_scope :not_turn_of, lambda{|user_id| 
    { :conditions => ['current_player_id != ?', user_id ]}
  }
  named_scope :public_g, :conditions => { :status => PUBLIC }
  named_scope :public_r18, :conditions => { :status => PUBLIC_R18 }
  named_scope :public_all, :conditions => ["(games.status = ? OR games.status = ?)", PUBLIC_R18, PUBLIC]

  named_scope :order_by_updated, :order => "games.updated_at DESC"
  named_scope :order_by_recency, :order => "games.published_at DESC"  
  named_scope :order_by_comments, :order => "games.comment_count DESC"  
  named_scope :order_by_recent_comments, :order => "games.last_comment_at DESC"  
  named_scope :order_by_started, :order => "games.created_at DESC"  
  named_scope :order_by_oldest, :order => "games.created_at ASC"  
  named_scope :order_by_finished, :order => "games.finished_at DESC"  
  named_scope :order_by_random, :order => ["RAND()"]

  named_scope :order_by, lambda{|sort_field|
    sql = case (sort_field || 'finished').to_s
    when 'updated'
      "games.updated_at DESC"
    when 'published_at'
      "games.published_at DESC"
    when 'comments'
      "games.comment_count DESC"
    when 'recent'
      "games.published_at DESC"
    when 'recent_comments'
      "games.last_comment_at DESC"  
    when 'started'
      "games.created_at DESC"  
    when 'finished'
      "games.finished_at DESC"  
    when 'random'
      "RAND()"
    else
      "games.finished_at DESC"
    end
    {:order => sql }
  }

  named_scope :open, :conditions => { :owner_id => nil }
  named_scope :available_to_user, lambda{|user_id|
    timeout_seconds = 1.day.to_i
    conditions = "(current_player_id IS NULL" +
      "   OR (assigned_at IS NOT NULL AND (NOW() - assigned_at) > :timeout)" +
      ")" +
      " AND (last_player_id != :user_id OR last_player_id IS NULL)" +
      " AND (second_last_player_id != :user_id OR second_last_player_id IS NULL)"
    data = { :user_id => user_id, :timeout => timeout_seconds }
    { :conditions => [conditions, data] }
  }
  named_scope :draw_phase, :conditions => { :phase => DRAW }
  named_scope :describe_phase, :conditions => { :phase => DESCRIBE }

  attr_accessor :fbsession

  def self.new_open
    game = new
    game.players = []
    game.phase = DRAW
    game.status = STARTED
    return game
  end

  def gallery_thumbnail_post
    thumbnail_post || posts.find(:first, :conditions => ['image_filename IS NOT NULL'])
  end

  def gallery_name
    name || first_description || "Game #{id}"
  end

  def first_description
    
    if post = posts.descriptions.first
      post.text 
    end
  end

  def descriptions
    posts.descriptions
  end

  def drawing_posts
    posts.drawings
  end

  def owner
    Player.find(:first, :conditions => ['game_id = ? AND user_id = ?', id, owner_id])
  end

  def invited_players
    players.active.except(owner_id)
  end

  def start(invited_player_ids)
    # 1. Create an array of the user IDs of players (owner and players invited to the game).
    # 2. Map to an array of Player objects.
    player_ids = [owner_id] + invited_player_ids
    self.players = player_ids.map{|x| Player.new(:user_id => x.to_i, :status => Player::ACTIVE) }
    self.players.each_with_index do |player, i|
      player.order_position = i
    end
    self.phase = DRAW
    self.status = STARTED
    self.current_player_id = owner_id
  end

  def is_draw_phase?
    self.phase == DRAW
  end

  def is_describe_phase?
    self.phase == DESCRIBE
  end

  def description
    if posts.size == 0 
      "whatever you like!"
    else
      '"' + posts.last.text + '"'
    end
  end

  def image_url_path
    posts.last.image_url_path
  end

  def finish!
    if owner_id 
      self.status = FINISHED
    else
      self.status = PUBLIC
    end
    self.finished_at = Time.now
    create_strip
    self.save!
  end

  def first_post?
    posts.size == 1
  end

  def is_finished?
    self.status >= FINISHED
  end

  def is_started?
    self.status == STARTED
  end

  def is_turn?(logged_in_user_id)
    is_started? and !current_player_id.nil? and current_player_id == logged_in_user_id.to_i
  end

  def next_players_turn!
    if owner.nil? # Open game
      self.second_last_player_id = self.last_player_id
      self.last_player_id = self.current_player_id
      self.current_player_id = nil
      save!
    else # Private game
      self.current_player_id = next_turn_player.user_id
      save!
    end
  end

  def skip_player!(player_id)
    if player_id.to_i == current_player_id
      next_players_turn!
    else
      raise "Player #{player_id} is not the current player"
    end
  end

  def turn_complete!
    self.phase = !phase # Toggles the phase (if draw then describe, if describe then draw)
    save!
    next_players_turn!
  end

  def current_turn_player
    Player.find(:first, :conditions => ['game_id = ? AND user_id = ?', id, current_player_id])
  end

  def next_turn_player
    next_active_player(current_player_id)
  end

  # Returns nil if that player is already an active player in this game.
  def get_player_to_add(player_id)
    player_to_add = players.find_by_user_id(player_id)
    if player_to_add.nil? # if the player to add has never been in this game
      player_to_add = players.build(:user_id => player_id.to_i, :status => Player::ACTIVE)
      return player_to_add
    else 
      player_to_add = players.find_by_user_id(player_id) 
      if player_to_add.status == Player::DROPPED
        # The player to add was once in this game but got dropped
        player_to_add.status = Player::ACTIVE
        # Put them at the end so they don't mess up our order calculations 
        player_to_add.order_position = players.size
        player_to_add.save!
        return player_to_add
      else 
        # The player to add is currently an active player in this game
        return nil
      end
    end
  end

  def add_player_at(position, player_id)
    player_to_add = get_player_to_add(player_id.to_i)
    if player_to_add
      ordered_players = players.active.in_order
      ordered_players.insert(position.to_i, player_to_add)
      transaction do
        ordered_players.each_with_index do |p, i|
          p.order_position = i
          p.save
        end
      end
      reload
    end
  end

  def add_player(player_id)
    transaction do
      order_position = players.size
      add_player_at(order_position, player_id)
    end
    reload
  end

  def rename(name_string, thumb_id)
    self.name = name_string.to_s
    self.thumbnail_post = posts.find(:first, :conditions => ['id = ?', thumb_id.to_i])
    transaction do
      save!
    end
  end

  def next_active_player(player_id)
    player = players.find_by_user_id(player_id)
    if player.nil?
      raise "Player #{player_id} is not in this game"
    end
    ordered_players = players.in_order
    index = ordered_players.index(player)
    # build an array of players ordered by turn with the next player at the
    # start that we can iterate through to find the next active player
    turn_players = ordered_players[(index + 1)..-1] + ordered_players[0..index]
    turn_players.find{|p| p.is_active? }
  end

  def author_user_ids
    posts.map(&:author_id).uniq
  end

  def create_strip
    return if RAILS_ENV == 'test'

    author_names = {}
    begin
      names_xml = fbsession.users_getInfo(:uids => author_user_ids, :fields => ["first_name", "last_name"])
      (names_xml/"user").each do |u|
        name = (u/"first_name").inner_text + ' ' + (u/"last_name").inner_text
        user_id = (u/"uid").inner_text.to_i
        author_names[user_id] = name
      end
    rescue
      logger.warn "Could not fetch author names from Facebook, no access to a Facebook session"
      author_user_ids.each do |id|
        author_names[id] = id.to_s
      end
    end

    post_images = posts.map{|post|
      post_img = nil
      if post.is_drawing?
        post_img = Magick::Image::read(post.image_disk_path).first
        post_img.border!(1, 1, 'grey')
      elsif post.is_description?
        post_img = render_text(post.text, 120) do |info|
          info.fill = "#000000"
          info.pointsize = 12
          info.antialias = true
          info.font = "Helvetica"
        end
      end
      # Create author tag image
      author_name = author_names[post.author_id] || "Someone"
      author_tag = render_text("-" + author_name, 120) do |info|
        info.fill = "grey"
        info.pointsize = 8
        info.antialias = true
        info.font = "Helvetica"
        info.gravity = Magick::EastGravity
      end
      [post_img, author_tag]
    }

    post_padding = 10
    author_padding = 0
    y = post_padding

    max_height = 604 - post_padding*2
    column_height = 0

    # Larger loop for column storage
    # Inner loop to create columns checking for 

    columns = []
    column = [] # Array of enough post and author images to fit in one column
    post_images.each do |post_img, author_img| 
      column_height += (post_img.rows + author_padding + author_img.rows + post_padding)
      if column_height < max_height
        column.push([post_img, author_img])
      else
        column_height = (post_img.rows + author_padding + author_img.rows + post_padding)
        columns.push(column)
        column = []
        column.push([post_img, author_img])
      end
    end
    columns.push(column) 
    #pp columns

    # Render columns
    columns = columns.map{|column|
      img_height = post_padding
      column.each do |post_img, author_img| 
        img_height += (post_img.rows + author_padding + author_img.rows + post_padding)
      end
      img = Magick::Image.new(148, img_height)
      y = post_padding
      column.each do |post_img, author_img| 
        x = (img.columns - post_img.columns)/2
        img.composite!(post_img, x, y, Magick::AtopCompositeOp)
        y += post_img.rows + author_padding
        x = (img.columns - author_img.columns)/2
        img.composite!(author_img, x, y, Magick::AtopCompositeOp)
        y += author_img.rows + post_padding
      end
      img
    }

    #pp columns

    # Render strip
    strip = Magick::Image.new((148 + 5) * columns.size, columns.max{|a, b| a.rows <=> b.rows }.rows)
    columns.each_with_index do |column, i|
      x = i * (148 + 5)
      if i > 0 # vertical line
        line_x = x - 2.5
        gc = Magick::Draw.new
        gc.stroke_width(3)
        gc.stroke('#bbbbbb')
        gc.line(line_x, 5, line_x, strip.rows - 5)
        gc.draw(strip)
      end
      strip.composite!(column, x, 0, Magick::AtopCompositeOp)
    end
    strip.write(strip_disk_path)
  end

  def strip_disk_path
    File.join(RAILS_ROOT, 'public', 'strips', "#{id}.png")
  end

  def strip_url_path
    File.join('/strips', "#{id}.png")
  end

  # returns [width, height]
  def strip_dims
    img = Magick::Image.read(strip_disk_path).first
    [img.columns, img.rows]
  end

  def days_left
    if is_finished?
      seconds = finished_at.to_i + STORAGE_DAYS*60*60*24 - Time.now.to_i
      days = seconds / 60 / 60 / 24
      return days
    else
      return nil
    end
  end

  def drop_player!(player_id)
    player_id = player_id.to_i
    transaction do
      player = players.find_by_user_id(player_id)
      player.status = Player::DROPPED
      player.save!

      if players.active.empty?
        errors.add_to_base("Cannot drop the last active player")
        raise ActiveRecord::RecordInvalid, self
      elsif player_id == owner_id
        self.owner_id = players.active.first.user_id
      end

      if current_player_id == player_id
        self.current_player_id = next_turn_player.user_id
      end

      save!
    end
  end

  def is_player?(user_id)
    players.find(:first, :conditions => ["status = ? AND user_id = ?", Player::ACTIVE, user_id])
  end

  def increment_comment_count
    self.comment_count += 1
    self.last_comment_at = Time.now
    save!
  end

  def decrement_comment_count
    if self.comment_count > 0 # People may delete posts made before comment tracking was implemented.
      self.comment_count -= 1
    end
    save!
  end

  def assign_player!(user_id)
    add_player(user_id)
    self.current_player_id = user_id
    self.assigned_at = Time.now
    save!
  end

  private

  def notify_new_owner
    if owner_id_changed?
      # TODO: notify new owner
    end
  end

  def validate_on_create
    super

    if players.size > length
      # not everybody will get a go :(
      errors.add_to_base("Game must be long enough for everybody to have a turn")
    end
  end

end
