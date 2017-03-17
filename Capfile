load 'deploy' if respond_to?(:namespace) # cap2 differentiator
Dir['vendor/plugins/*/recipes/*.rb'].each { |plugin| load(plugin) }
Dir['lib/capistrano/*.rb'].each { |extension| load(extension) }
load 'config/deploy'
