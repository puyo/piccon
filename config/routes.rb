ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.

  map.games '/', :controller => 'site', :action => 'index'
  map.game '/game/view/:id', :controller => 'game', :action => 'view', :conditions => { :method => :post }
  map.game_iframe '/game/iframe/:id', :controller => 'game', :action => 'iframe', :conditions => { :method => :get }
  map.game_info '/game/info/:id', :controller => 'game', :action => 'info', :conditions => { :method => :post }
  map.game_post '/game/post/:id', :controller => 'game', :action => 'post', :conditions => { :method => :post }
  map.gallery '/gallery/:rating', :controller => 'gallery', :action => 'index', :conditions => { :method => :post }
  map.help '/help', :controller => 'site', :action => 'help', :conditions => { :method => :post }
  map.welcome '/welcome', :controller => 'site', :action => 'welcome', :conditions => { :method => :post }
  map.new_game '/game/new', :controller => 'game', :action => 'new', :conditions => { :method => :post }
  map.new_open_game '/game/new_open', :controller => 'game', :action => 'new_open', :conditions => { :method => :post }
  map.draw '/draw', :controller => 'site', :action => 'draw', :conditions => { :method => :post }
  map.write '/write', :controller => 'site', :action => 'write', :conditions => { :method => :post }
  map.join_game '/game/join/:id', :controller => 'game', :action => 'join', :conditions => { :method => :post }
  map.current_games '/current_games', :controller => 'site', :action => 'current_games', :conditions => { :method => :post }
  map.finished_games '/finished_games', :controller => 'site', :action => 'finished_games', :conditions => { :method => :post }
  map.dev_current_games '/dev_current_games', :controller => 'site', :action => 'dev_current_games', :conditions => { :method => :post }
  map.dev_finished_games '/dev_finished_games', :controller => 'site', :action => 'dev_finished_games', :conditions => { :method => :post }
  map.game_invited '/game/invited_to_game/:id', :controller => 'game', :action => 'invited_to_game', :conditions => { :method => :post }
  map.invited '/invited', :controller => 'site', :action => 'invited', :conditions => { :method => :post }
  map.invite '/invite', :controller => 'site', :action => 'invite', :conditions => { :method => :post }
  map.game_add_player '/game/add_player/:id', :controller => 'game', :action => 'add_player', :conditions => { :method => :post }
  map.game_rename '/game/rename/:id', :controller => 'game', :action => 'rename', :conditions => { :method => :post }
  map.game_feature '/game/feature/:id', :controller => 'game', :action => 'feature', :conditions => { :method => :post }
  map.game_skip '/game/skip/:id', :controller => 'game', :action => 'skip', :conditions => { :method => :post }
  map.game_skipped '/game/skipped/:id', :controller => 'game', :action => 'skipped', :conditions => { :method => :post }
  map.game_leave '/game/leave/:id', :controller => 'game', :action => 'leave', :conditions => { :method => :post }
  map.game_left '/game/left/:id', :controller => 'game', :action => 'left', :conditions => { :method => :post }
  map.game_kick '/game/kick/:id', :controller => 'game', :action => 'kick', :conditions => { :method => :post }
  map.game_kicked '/game/kicked/:id', :controller => 'game', :action => 'kicked', :conditions => { :method => :post }
  map.game_save_to_photos '/game/save_to_photos/:id', :controller => 'game', :action => 'save_to_photos', :conditions => { :method => :post }
  map.game_save '/game/save_strip/:id', :controller => 'game', :action => 'save_strip'
  map.game_deleted '/game/deleted/:id', :controller => 'game', :action => 'deleted', :conditions => { :method => :post }
  map.game_make_public '/game/make_public/:id', :controller => 'game', :action => 'make_public', :conditions => { :method => :post }
  map.game_make_public_r18 '/game/make_public_r18/:id', :controller => 'game', :action => 'make_public_r18', :conditions => { :method => :post }
  map.game_flag_offensive '/game/flag_offensive/:id', :controller => 'game', :action => 'flag_offensive', :conditions => { :method => :post }
  map.game_set_privacy '/game/set_privacy/:id', :controller => 'game', :action => 'set_privacy', :conditions => { :method => :post }
  map.root :controller => "site", :action => "index", :conditions => { :method => :post }

  map.old_games '/game/index', :controller => "site", :action => "old_index"

  # See how all your routes lay out with "rake routes"
end
