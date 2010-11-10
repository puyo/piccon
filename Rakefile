# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)
require 'rake'
require 'fileutils'

Piccon::Application.load_tasks

def mxmlc
  if flex = ENV['FLEX_HOME']
    File.join(flex, 'bin/mxmlc')
  elsif File.exist?(File.expand_path('~/flex/bin/mxmlc'))
    '~/flex/bin/mxmlc'
  else
    'mxmlc'
  end
end

swf = 'public/flash/PicconDrawArea.swf'

desc 'Compile flash drawing widget'
task :flash => swf

file swf => Dir['flash/*'] do |t|
  sh "#{mxmlc} flash/PicconDrawArea.as -o #{t.name}"
end
