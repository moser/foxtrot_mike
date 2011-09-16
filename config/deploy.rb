require 'bundler/capistrano'
$:.unshift(File.expand_path('./lib', ENV['rvm_path'])) # Add RVM's lib directory to the load path.
require "rvm/capistrano"                  # Load RVM's capistrano plugin.
set :rvm_ruby_string, '1.9.2'        # Or whatever env you want it to run in.

set :application, "openinno"

set :user, "deploy"
set :scm, :git
set :repository, "git://github.com/moser/foxtrot_mike.git"
set :branch, "master"
set :git_shallow_clone, 1
set :scm_verbose, true
set :deploy_to, "/var/rails/fm"
set :deploy_via, :remote_cache
set :use_sudo, false

role :web, "fm.vielsmaier.net"
role :app, "fm.vielsmaier.net"
role :db,  "fm.vielsmaier.net", :primary => true


namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end
 
#namespace :bundler do
#  desc "Symlink bundled gems on each release"
#  task :symlink_bundled_gems, :roles => :app do
#    run "mkdir -p #{shared_path}/bundled_gems"
#    run "ln -nfs #{shared_path}/bundled_gems #{release_path}/vendor/bundle"
#  end

#  desc "Install for production"
#  task :install, :roles => :app do
#    run "cd #{release_path} && bundle install --production"
#  end

#end

#after 'deploy:update_code', 'bundler:symlink_bundled_gems'
#after 'deploy:update_code', 'bundler:install'
