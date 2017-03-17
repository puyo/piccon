class GameController < ApplicationController

  before_filter :require_facebook_install, :except => [:view]
  before_filter :require_facebook_login, :except => [:view]

  def new
    # new game form (view)
    # create a game if given the parameters

    @warning = false

    @friends_with_app = get_friends_with_app

    # If input has already been entered into the form, keep the input.
    if params.has_key?(:game)
      @game = Game.new(:owner_id => fb_user_id, :length => params[:game][:length])
      ids = params[:ids].to_a.map{|id| id.to_i }
      @game.start(ids)
      if params[:warning] != 'seen' and ids.size < 2
        @warning = true
        flash.now[:warnings] = ["The recommended minimum number of invites is 2. You can continue, but it might not be much fun. Click Create Game again to proceed."]
        return render(:action => :new)
      end
      if @game.save
        @friends_to_exclude = params[:fb_sig_friends].split(',')
        @friends_who_need_invites = get_friends_who_need_invites(params[:ids].to_a)
        @friends_to_exclude -= @friends_who_need_invites
        if @friends_who_need_invites.any?
          return render(:action => :invite_to_game)
        else
          return redirect_to(game_path(@game))
        end
      else
        flash.now[:errors] = @game.errors.full_messages.join(', ')
      end
      # On the first viewing of the new game form, populate the fields with default values.
    else
      # new empty game with default values
      @game = Game.new(:owner_id => fb_user_id)
      flash.clear
    end
    render :action => :new
  end

  def invited_to_game
    redirect_to game_path(params[:id])
  end

  def new_open
    @game = Game.new_open
    @game.save
    @game.assign_player!(fb_user_id)
    redirect_to(game_path(@game))
  end

  def join
    @game = Game.find(params[:id])
    @game.assign_player!(fb_user_id)
    redirect_to(game_path(@game))
  end

  def view
    @game = Game.find(params[:id])
    if @game.is_turn?(fb_user_id)
      if @game.is_draw_phase?
        render :action => :view_draw_phase
      elsif @game.is_describe_phase?
        render :action => :view_describe_phase
      end
    else
      if @game.is_finished?
        render :action => :view_finished_game
      else
        render :action => :info
      end
    end
  end

  def set_privacy
    @game = Game.find(params[:id])
    if params.has_key?(:rating_selection)
      change_privacy(params[:rating_selection].to_s)
    end
    if params[:parent_view] == 'view'
      redirect_to(game_path(@game))
    elsif params[:parent_view] == 'rename'
      redirect_to(game_rename_path(@game))
    elsif params[:parent_view] == 'index_g'
      redirect_to(gallery_g_path)
    elsif params[:parent_view] == 'index_r18'
      redirect_to(gallery_r18_path)
    elsif params[:parent_view] == 'index_all'
      redirect_to(gallery_all_path)
    else
      redirect_to(game_info_path(@game))
    end
  end

  def iframe
    @game = Game.find(params[:id])
    render :action => :iframe, :layout => "iframe_layout"
  end

  def post
    # id
    # current user (validated)
    # text
    # image (file upload)

    @game = Game.find(params[:id])

    post = @game.posts.build(:author_id => fb_user_id)
    post.fbsession = fbsession

    if params["Filedata"] and params["Filename"] # they're posting an image
      post.image = params["Filedata"]
    elsif params["text"] # they're posting a description
      post.text = params["text"]
    end

    if post.save
      flash[:notices] = ['Post successful']
    else
      logger.error post.errors.full_messages.join("\n")
      flash[:errors] = post.errors.full_messages
    end

    if post.warnings.any?
      flash[:warnings] = post.warnings
    end

    params["Filedata"] = nil
    post.image = nil

    redirect_to games_path
  end

  def leave
    # id
    # current user (validated)

    @game = Game.find(params[:id])

    if @game.is_finished?
      raise "This game is finished"
    end

    begin
      case params[:confirm] 

      when 'leave'
        @game.drop_player!(fb_user_id)
        flash[:notices] = ["Left game"]
        return redirect_to(game_left_path(@game))

      when 'finish_early'
        if fb_user_id != @game.owner_id
          @game.errors.add_to_base("You cannot end this game because you are not running it")
          raise ActiveRecord::RecordInvalid, @game
        end
      @game.fbsession = fbsession
      @game.finish!
      return redirect_to(game_path(@game))

      when 'destroy'
        if fb_user_id != @game.owner_id
          @game.errors.add_to_base("You cannot delete this game because you are not running it")
          raise ActiveRecord::RecordInvalid, @game
        end
      if @game.players.active.size > 1
        @game.errors.add_to_base("You cannot delete this game because it still has other players in it")
        raise ActiveRecord::RecordInvalid, @game
      end
      @game.destroy
      return redirect_to(game_deleted_path(@game))

      end
    rescue
      flash.now[:errors] = @game.errors.full_messages
    end
    render :action => 'leave'
  end

  def kick
    # id
    # current user (validated)
    # player_id

    @game = Game.find(params[:id])

    if @game.owner_id == fb_user_id.to_i
      if params[:confirm] == 'yes'
        begin
          @game.drop_player!(params[:player_id])
          flash.now[:notices] = ["Player kicked"]
          return render(:action => 'kicked')
        rescue
          flash.now[:errors] = @game.errors.full_messages
        end
      end
    else
      flash.now[:errors] = ["You are not the game owner"]
    end

    render :action => 'kick'
  end

  def skip
    # id
    # current user (validated)

    @game = Game.find(params[:id])

    if (@game.owner_id == fb_user_id.to_i) or (@game.is_player?(fb_user_id.to_i) and (Time.now - @game.updated_at > 60*60*24*7))
      if params[:confirm] == 'yes'
        begin
          @game.skip_player!(params[:player_id])
          flash.now[:notices] = ["Player skipped"]
          return render(:action => 'skipped')
        rescue
          flash.now[:errors] = @game.errors.full_messages
        end
      end
    else
      flash.now[:errors] = ["You are not the game owner"]
    end

    render :action => 'skip'
  end

  def add_player
    # add player game form (view)
    # Adds a new player to a game already in progress.

    @game = Game.find(params[:id])

    if @game.owner_id != fb_user_id.to_i
      flash[:errors] = ["You are not the game owner"]
      return redirect_to(games_path)
    end

    if params.has_key?(:friend_selector_name)
      # add the player
      if !params[:friend_selector_name].blank? and !params[:friend_selector_id].blank?
        @game.add_player_at(params[:insert_position], params[:friend_selector_id])
      end
    end

    # view
    @current_player_ids = @game.players.active.in_order.map{|x| x.user_id }
  end

  def rename
    # id

    @game = Game.find(params[:id])

    if @game.owner_id != fb_user_id.to_i
      flash[:errors] = ["You are not the game owner"]
      return redirect_to(games_path)
    end

    if params.has_key?(:name_selection)
      if params[:name_selection] == "use_text_field"
        @game.rename(params[:text_field], params[:thumb_selection])
      else
        @game.rename(params[:name_selection], params[:thumb_selection])
      end
    end
  end

  def save_to_photos
    # id
    # current user (validated)
    #
    # TODO: check errors

    @game = Game.find(params[:id])
    begin
      upload_xml = fbsession.photos_upload(:file => File.read(@game.strip_disk_path), :type => 'image/png', :filename => "piccon-" + File.basename(@game.strip_disk_path))
    rescue RFacebook::FacebookSession::RemoteStandardError => e
      case e.code
      when 1
        flash[:errors] = "Error uploading to Facebook Photos: Facebook Photos rejected this image. Facebook Photos has some undocumented restrictions on image sizes. We apologise for the inconvenience."
      else
        flash[:errors] = "Error uploading to Facebook Photos: Error code #{e.code}"
      end
      return redirect_to(game_path(@game))
    end

    @aid = (upload_xml/"aid").inner_text # WTF?
    @pid = (upload_xml/"pid").inner_text # WTF?

    # this is for tagging people... maybe we could tag all the people in the game...
    #tag_xml = fbsession.photos_addTag(:pid => @pid, :tag_text => 'Piccon')

    album_xml = fbsession.photos_getAlbums(:aids => [@aid])
    @link = (album_xml/"link").inner_text

    render :action => 'saved_to_photos'
  end

  def save_strip
    @game = Game.find(params[:id])
    send_file @game.strip_disk_path, :filename => "piccon-#{@game.id}.png"
  end

  def info
    @game = Game.find(params[:id])
  end

  def left
    # nothing
  end

  def deleted
    # nothing
  end

  def change_privacy(privacy)
    @game = Game.find(params[:id])
    if privacy != "R18"
      if fb_user_id != @game.owner_id
        @game.errors.add_to_base("You cannot make this game public because you are not running it")
        raise ActiveRecord::RecordInvalid, @game
      end
    end

    if @game.status <= 20
      @game.published_at = Time.now
    end

    case privacy
    when 'G'
    @game.status = Game::PUBLIC
    when 'R18'
    @game.status = Game::PUBLIC_R18
    when 'private_G'
    @game.status = Game::FINISHED
    when 'private_R18'
    @game.status = Game::PRIVATE_R18
    end
    @game.save!
  rescue
    flash[:errors] = @game.errors.full_messages
    redirect_to game_path(@game)
  end

  def flag_offensive
    raise "TODO"
  end

end
