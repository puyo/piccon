module GameHelper

  def status(game)
    if game.is_finished?
      link_to("View", game_path(game))
    elsif game.is_turn?(fbsession.session_user_id)
      link_to('<span class="action_required">You</span>', game_path(game))
    elsif game.is_started? and game.current_player_id != fbsession.session_user_id # not our turn
      link_to(%{<fb:name ifcantsee="Someone" firstnameonly="true" useyou="false" uid="#{game.current_player_id}"/>}, game_path(game))
    end
  end

  def phase(game)
    if game.is_draw_phase?
      link_to("Play&nbsp;now! (Draw)", game_path(game))
    else
      link_to("Play&nbsp;now! (Write)", game_path(game))
    end
  end

  def join(game)
    if game.is_draw_phase?
      link_to("Play&nbsp;now! (Draw)", join_game_path(game))
    else
      link_to("Play&nbsp;now! (Write)", join_game_path(game))
    end
  end

  def options(game)
    if game.current_player_id != fbsession.session_user_id.to_i # not our turn
      # nudge link
      id = game.current_player_id.to_s
      subject = "Your turn in Piccon!"
      msg = "Hi, it's your turn in Piccon. Please play, because I'm really keen to find out how our game turns out. :) The link to our game is " + game_path(game)
      nudge_link = "<a href=\"http://facebook.com/message.php?id=" + id + "&subject=" + subject + "&msg=" + msg + "\">Nudge</a>"
      # skip link
      if (game.owner_id == fbsession.session_user_id.to_i) or (Time.now - game.updated_at > 60*60*24*7)
        skip_link = ",&nbsp;" + link_to('Skip', game_skip_path(game, :player_id => game.current_player_id))
      else 
        skip_link = ""
      end
      options_links = "(" + nudge_link + skip_link + ")"
    end 
  end
end
