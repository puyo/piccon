require File.dirname(__FILE__) + '/../test_helper'

class GameTest < ActiveSupport::TestCase

  #fixtures :games
  #fixtures :posts
  #fixtures :players

  def test_create
    game = Game.new(:owner_id => 1, :length => 5)
    game.start([2])
    assert game.save, game.errors.full_messages.join("\n")
    g2 = Game.find(game.id)
    assert_equal game.id, g2.id, "Game IDs should match"
  end

  def test_posts
    assert_equal 3, games("lucyandgreg").posts.size, "Expected 3 posts"
  end

  def test_drop_player
    game = games("lucyandgreg")
    prev_played_by = Game.played_by(2).size
    game.drop_player!(2)
    assert_equal 1, game.players.active.size, "Expected 1 active player left"
    assert_equal 1, game.next_turn_player.user_id, "Expected Greg to go next"
    assert_equal prev_played_by - 1, Game.played_by(2).size
  end

  def test_drop_owner
    game = games("lucyandgreg")
    game.drop_player!(1)
    assert_equal 1, game.players.active.size, "Expected 1 active player left"
    assert_equal 2, game.owner.user_id
    assert_equal 2, game.next_turn_player.user_id, "Expected Lucy to go next"
  end

  def test_drop_last_player
    game = Game.new(:owner_id => 1, :length => 5)
    game.start([])
    assert game.save, game.errors.full_messages.join("\n")
    assert_raise(ActiveRecord::RecordInvalid) do 
      game.drop_player!(1)
    end
  end

  def test_finish_early
    game = games("lucyandgreg")
    game.finish!
    # TODO: assertions?
  end

  def test_delete_strip_on_destroy
    # TODO
  end

  def test_change_title

  end

  def test_change_thumbnail_post

  end

  def test_game_finish_len_3
    game = Game.new(:owner_id => 1, :length => 3)
    game.start([2])
    game.save!

    post_drawing!(game, 1)
    assert !game.is_finished?, "Game finished unexpectedly"

    post_desc!(game, 2)
    assert !game.is_finished?, "Game finished unexpectedly"

    post_drawing!(game, 1)
    assert game.is_finished?, "Game should be finished"
  end

  def test_game_finish_len_2
    game = Game.new(:owner_id => 1, :length => 2)
    game.start([2])
    game.save!

    post_drawing!(game, 1)
    assert !game.is_finished?, "Game finished unexpectedly"

    post_desc!(game, 2)
    assert game.is_finished?, "Game should be finished"
  end

  def test_create_not_enough_rounds
    game = Game.new(:owner_id => 1, :length => 2)
    game.start([2, 3, 4])
    game.save
    assert_match /long enough/, game.errors.full_messages.to_s, "Expected error about not enough rounds"
  end

  def test_add_player
    game = Game.new(:owner_id => 1, :length => 9)
    game.start([2, 3, 4, 5]) # Five player game
    game.save!

    game.add_player_at(3, 6)
    assert_equal Player.find_by_user_id(6), game.players.find_by_user_id(6), "Expected player 6"
    assert_equal 3, game.players.find_by_user_id(6).order_position, "Expected to have player 6 at index 3"
    assert_equal 6, game.players.active.size, "Expected 6 players in game"
  end

  def test_add_kicked_player
    game = Game.new(:owner_id => 1, :length => 9)
    game.start([2, 3, 4, 5]) # Five player game
    game.save!
    player = game.players.find_by_user_id(5)
    player.status = Player::DROPPED
    player.save!

    game.add_player_at(2, 5)
    assert_equal 2, game.players.find_by_user_id(5).order_position, "Expected to have player 5 at index 2"
    assert_equal 5, game.players.active.size, "Expected 5 players in game"
  end

  def test_turn_player
    game = Game.new(:owner_id => 1, :length => 9)
    game.start([2, 3, 4, 5]) # Five player game
    game.save!
    assert_equal 1, game.current_turn_player.user_id, "Expected owner to have first turn"
    assert_equal 2, game.next_turn_player.user_id, "Expected player 2 to be next player"

    post_drawing!(game, 1) # Owner (player 1) draws a picture
    assert_equal 2, game.current_turn_player.user_id, "Expected player 2 to be current player"
    assert_equal 3, game.next_turn_player.user_id, "Expected player 3 to be next player"

    post_desc!(game, 2) # Player 2 writes a desciption
    game.drop_player!(2) # Player 2 leaves after taking a turn
    assert_equal 3, game.current_turn_player.user_id, "Expected player 3 to be current player"
    assert_equal 4, game.next_turn_player.user_id, "Expected player 4 to be next player"

    game.drop_player!(3) # Player 3 leaves instead of taking a turn
    assert_equal 4, game.current_turn_player.user_id, "Expected player 4 to be current player"
    assert_equal 5, game.next_turn_player.user_id, "Expected player 5 to be next player"
    
    post_drawing!(game, 4) # Player 4 draws a picture
    assert_equal 5, game.current_turn_player.user_id, "Expected player 5 to be current player"
    assert_equal 1, game.next_turn_player.user_id, "Expected player 1 to be next player"

    post_desc!(game, 5) # Player 5 writes a desciption
    assert_equal 1, game.current_turn_player.user_id, "Expected owner (player 1) to be current player"
    assert_equal 4, game.next_turn_player.user_id, "Expected player 4 to be next player"

    post_drawing!(game, 1) # Player 1 draws a picture
    assert_equal 4, game.current_turn_player.user_id, "Expected player 4 to be current player"
    assert_equal 5, game.next_turn_player.user_id, "Expected player 5 to be next player"

    game.drop_player!(5) # Player 5 leaves.
    assert_equal 4, game.current_turn_player.user_id, "Expected player 4 to be current player"
    assert_equal 1, game.next_turn_player.user_id, "Expected player 1 to be next player"

    post_desc!(game, 4) # Player 4 writes a desciption
    assert_equal 1, game.current_turn_player.user_id, "Expected player 1 to be current player"
    assert_equal 4, game.next_turn_player.user_id, "Expected player 4 to be next player"

    post_drawing!(game, 1) # Player 1 draws a picture
    assert_equal 4, game.current_turn_player.user_id, "Expected player 4 to be current player"
    assert_equal 1, game.next_turn_player.user_id, "Expected player 1 to be next player"

    game.drop_player!(1) # Owner (player 1) leaves. Player 4 becomes owner.
    assert_equal 4, game.current_turn_player.user_id, "Expected player 4 to be current player"
    assert_equal 4, game.next_turn_player.user_id, "Expected player 4 to be next player"

    post_desc!(game, 4) # Player 4 writes a desciption
    assert_equal 4, game.current_turn_player.user_id, "Expected player 4 to be current player"
    assert_equal 4, game.next_turn_player.user_id, "Expected player 4 to be next player"

    post_drawing!(game, 4) # Player 1 draws a picture
    assert_equal 4, game.current_turn_player.user_id, "Expected player 4 to be current player"
    assert_equal 4, game.next_turn_player.user_id, "Expected player 4 to be next player"
  end

  def test_open_games
    game = Game.new_open
    game.save!

    games = Game.open.available_to_user(1)
    assert_equal 1, games.size
    assert_equal game, games.first
    assert_nil game.assigned_at
    assert_nil game.current_player_id
    assert_nil game.owner_id
    assert_nil game.last_player_id
    assert_nil game.second_last_player_id

    game.assign_player!(1)
    assert_equal 0, Game.open.available_to_user(1).size
    assert_not_nil game.assigned_at
  end

  private

  def post_drawing!(game, author_id)
    post = game.posts.build(:image => mock_image_data, :author_id => author_id)
    post.save!
    game.reload
  end

  def post_desc!(game, author_id, text=nil)
    text ||= "foo bar text posted by #{author_id}"
    post = game.posts.build(:text => text, :author_id => author_id)
    post.save!
    game.reload
  end

end
