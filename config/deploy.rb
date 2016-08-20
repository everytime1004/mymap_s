# config valid only for current version of Capistrano
lock '3.6.0'

require "bundler/capistrano"
 
set :application, "mymap_s"
 
# Setup for SCM(Git)
set :scm, :git
set :repository, "git@github.com:everytime1004/mymap_s.git"
# set :repository, "https://github.com/everytime1004/likeholic_server.git"
set :branch, "master"

set :unicorn_binary, "/usr/bin/unicorn"
set :unicorn_config, "#{current_path}/config/unicorn.rb"
set :unicorn_pid, "#{current_path}/tmp/pids/unicorn.pid"

set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system')
 
default_run_options[:pty] = true
 
after "deploy", "deploy:cleanup"
 
namespace :deploy do
  %w[start stop restart].each do |command|
    desc "#{command} unicorn server"
    if command == 'restart'
      invoke 'unicorn:reload'
    else
      task command, roles: :app, except: {no_release: true} do
        run "/etc/init.d/unicorn_#{application} #{command}"
      end
    end
  end
 
  task :setup_config, roles: :app do
    sudo "ln -nfs #{current_path}/config/nginx.conf /etc/nginx/sites-enabled/#{application}"
    sudo "ln -nfs #{current_path}/config/unicorn_init.sh /etc/init.d/unicorn_#{application}"
    run "mkdir -p #{shared_path}/config"
    put File.read("config/database.example.yml"), "#{shared_path}/config/database.yml"
    puts "Now edit the config files in #{shared_path}."
  end
  after "deploy:setup", "deploy:setup_config"
 
  task :symlink_config, roles: :app do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
  end
  after "deploy:finalize_update", "deploy:symlink_config"
 
  desc "Make sure local git is in sync with remote."
  task :check_revision, roles: :web do
    unless `git rev-parse HEAD` == `git rev-parse origin/master`
      puts "WARNING: HEAD is not the same as origin/master"
      puts "Run `git push` to sync changes."
      exit
    end
  end
  before "deploy", "deploy:check_revision"
end