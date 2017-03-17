require 'tempfile' # Dir.tmpdir
require 'rubygems'
gem "capistrano", ">=2.4.3"
gem "termios", ">=0.9.4" # to hide password prompts

# ----------------------------------------------------------------------------
set :application, "piccon"
set :repository, "http://svn.cheekydevilgames.com/piccon/trunk/"
set :scm, :subversion
set :scm_username, "greg"
set :scm_prefer_prompt, true
set :deploy_via, :copy # zip locally and upload rather than checkout remotely
set :copy_dir, File.join(Dir.tmpdir, 'capistrano') # local checkout dir
set :copy_compression, :bzip2
set :copy_strategy, :export
set :use_sudo, false # shared host
set :mxmlc, "/opt/flex/bin/mxmlc"
set :copy_compile do
  system(format("%s %s", configuration[:mxmlc], File.join(destination, 'flash', 'PicconDrawArea.as'), :pty => true))
end

# ----------------------------------------------------------------------------
# Environments

task :local do
  set :host, "localhost"
  role :app, host
  role :web, host
  role :db,  host, :primary => true

  set :deploy_to, "/home/greg/piccondeployment/#{application}/"
end

task :production do
  set :host, "hopefullyfun.com"
  role :app, host
  role :web, host
  role :db,  host, :primary => true

  set :deploy_to, "/home/puyo/#{application}/"
  set :user, "puyo"
end

# ----------------------------------------------------------------------------
# Customise Default Capistrano Tasks

namespace :deploy do
  # Overwrite the deploy:restart task to work on a shared host.
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{current_path}/script/process/reaper --dispatcher=dispatch.fcgi"
  end

  # Create shared drawings, strips and config (database.yml) files.
  task :setup_piccon_shared_dirs, :except => { :no_release => true } do
    dirs = %w(drawings strips config).map { |d| File.join(shared_path, d) }
    run "#{try_sudo} mkdir -p #{dirs.join(' ')} && #{try_sudo} chmod g+w #{dirs.join(' ')}"
  end

  def relink(target, link)
    run "rm -rf #{link} && ln -nfs #{target} #{link}"
  end

  task :link_database_yml, :roles => :app, :except => { :no_release => true } do
    relink "#{shared_path}/config/database.yml", "#{release_path}/config/database.yml"
  end

  task :link_drawings, :roles => :app, :except => { :no_release => true } do
    relink "#{shared_path}/drawings", "#{release_path}/public/drawings"
  end

  task :link_strips, :roles => :app, :except => { :no_release => true } do
    relink "#{shared_path}/strips", "#{release_path}/public/strips"
  end

  task :set_production_env, :roles => :app, :except => { :no_release => true } do
    run "sed -e \"s/^# ENV.*$/ENV['RAILS_ENV'] = 'production'/\" -i #{release_path}/config/environment.rb"
  end

  task :chmod, :roles => :app, :except => { :no_release => true } do
    run "chmod -R 755 #{release_path}/public"
  end

  namespace :web do
    task :disable, :roles => :web do
      on_rollback { delete "#{shared_path}/system/maintenance.html" }

      require 'erb'
      template = File.read("./app/views/layouts/maintenance.html.erb")
      deadline = ENV['UNTIL']
      reason = ENV['REASON']
      maintenance = ERB.new(template).result(binding)

      put maintenance, "#{shared_path}/system/maintenance.html", 
        :mode => 0644
    end
  end

end

after "deploy:setup", "deploy:setup_piccon_shared_dirs"
after "deploy:update_code", "deploy:link_database_yml"
after "deploy:update_code", "deploy:link_drawings"
after "deploy:update_code", "deploy:link_strips"
after "deploy:update_code", "deploy:set_production_env"
after "deploy:update_code", "deploy:chmod"
