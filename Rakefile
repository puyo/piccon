# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require(File.join(File.dirname(__FILE__), 'config', 'boot'))

require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

require 'tasks/rails'

task :bad_games => :environment do
  pp Game.find(:all).select{|g| g.posts.select{|p| !g.players.map{|player| player.user_id }.include?(p.author_id) }.any? }
end
