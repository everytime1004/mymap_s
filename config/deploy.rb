# config valid only for current version of Capistrano

# require "bundler/capistrano"
 
set :application, "mymap_s"
 
# Setup for SCM(Git)
set :repo_url, "git@github.com:everytime1004/mymap_s.git"
set :branch, "master"
# set :repository, "https://github.com/everytime1004/likeholic_server.git

set :unicorn_binary, "/usr/bin/unicorn"
set :unicorn_config, "#{current_path}/config/unicorn.rb"
set :unicorn_pid, "#{current_path}/tmp/pids/unicorn.pid"

set :use_sudo, false
set :bundle_binstubs, nil
set :linked_files, fetch(:linked_files, []).push('config/database.yml')
set :linked_files, fetch(:linked_files, []).push('config/application.yml')
set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system')

after 'deploy:publishing', 'deploy:restart'

namespace :figaro do
    desc "SCP transfer figaro configuration to the shared folder"
    task :setup do
        on roles(:app) do
            upload! "config/application.yml", "#{shared_path}/application.yml", via: :scp
        end
    end

    desc "Symlink application.yml to the release path"
    task :symlink do
        on roles(:app) do
            execute "ln -sf #{shared_path}/application.yml #{release_path}/config/application.yml"
        end
    end

end

namespace :deploy do
  task :restart do
    invoke 'unicorn:reload'
  end

  task :printenv do 
  	run "printenv"
  end
end
 
# namespace :deploy do
# 	%w[start stop restart].each do |command|
# 		if command == 'restart'
# 			task :restart do
# 				on primary roles :app do
# 					invoke 'unicorn:reload'
# 				end
#   			end
#   		else
# 		    desc "#{command} unicorn server"
# 		    task command, roles: :app, except: {no_release: true} do
# 		      run "/etc/init.d/unicorn_#{application} #{command}"
# 		    end
# 		end
#   	end
 
#   	task :setup_config, roles: :app do
#     	sudo "ln -nfs #{current_path}/config/nginx.conf /etc/nginx/sites-enabled/#{application}"
#     	sudo "ln -nfs #{current_path}/config/unicorn_init.sh /etc/init.d/unicorn_#{application}"
#     	run "mkdir -p #{shared_path}/config"
#     	put File.read("config/database.example.yml"), "#{shared_path}/config/database.yml"
#     	puts "Now edit the config files in #{shared_path}."
#   	end
#   	after "deploy:setup", "deploy:setup_config"
 
#   	task :symlink_config, roles: :app do
#     	run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
#  	end
#   	after "deploy:finalize_update", "deploy:symlink_config"
 
#  	desc "Make sure local git is in sync with remote."
#   	task :check_revision, roles: :web do
#    		unless `git rev-parse HEAD` == `git rev-parse origin/master`
#       	puts "WARNING: HEAD is not the same as origin/master"
#       	puts "Run `git push` to sync changes."
#       	exit
#     	end
#   	end
#   	before "deploy", "deploy:check_revision"
# end