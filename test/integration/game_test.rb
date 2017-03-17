require "#{File.dirname(__FILE__)}/../test_helper"

class GameTest < ActionController::IntegrationTest
  def fbparams
    {
      "fb_sig_time"=> Time.now.to_f.to_s,
      "fb_sig"=>"fbsig",
      "fb_sig_in_new_facebook"=>"1",
      "fb_sig_locale"=>"en_US",
      "fb_sig_position_fix"=>"1", 
      "fb_sig_in_canvas"=>"1",
      "fb_sig_request_method"=>"GET", 
      "fb_sig_expires"=>"0",
      "fb_sig_friends"=>"", 
      "fb_sig_added"=>"1",
      "fb_sig_api_key"=>"apikey",
      "fb_sig_user"=>"1",
      "fb_sig_profile_update_time"=>"1216976910",
      "auth_token" => "authtoken",
    }
  end

  def test_index
    fbsession.expects(:session_user_id).returns('1').at_least_once
    post "/", fbparams
    assert_response :success
    assert_template "site/index", response.body
    assert_match(/Finished/, response.body, 'Expected the word "Finished" in game index')
  end

  def test_kick
    fbsession.expects(:session_user_id).returns('1').at_least_once
    post("/game/kick/#{games('lucyandgreg').id}", fbparams.update({
      :player_id => '2',
      :confirm => 'yes',
    }))
    assert_equal 1, games('lucyandgreg').current_player_id
  end

  def test_first_post_notification_fail
    game = Game.new(:owner_id => 1, :length => 5)
    game.start([2])
    assert game.save, game.errors.full_messages.join("\n")
    exception = RFacebook::FacebookSession::RemoteStandardError
    fbsession.expects(:session_user_id).returns('1').at_least_once
    fbsession.expects(:feed_publishActionOfUser).raises(exception.new('could not publish feed', 1))
    fbsession.expects(:notifications_send).raises(exception.new('could not send notification', 1))
    post("/game/post/#{game.id}", fbparams.update({
      :Filedata => mock_image_data,
      :Filename => 'drawing.png',
    }))
    assert_match(/Unable to publish/, flash[:warnings].to_s)
    assert_match(/Unable to notify next player/, flash[:warnings].to_s)
    assert_response(:success)
    assert_match(/fb:redirect.*url=".*\/"/, response.body, 'Expected fb:redirect after post')
    assert_equal 1, game.posts.size
  end

  def test_publish_feed_story_fail
#    assert false, "TODO"
  end
end
