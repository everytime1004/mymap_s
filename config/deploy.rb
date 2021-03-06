# config valid only for current version of Capistrano

# require "bundler/capistrano"
 
set :application, "mymap_s"
 
# Setup for SCM(Git)
set :repo_url, "git@github.com:everytime1004/mymap_s.git"
set :branch, "master"
# set :repository, "https://github.com/everytime1004/likeholic_server.git

set :pty, true
set :use_sudo, false
set :stage, :production

set :puma_bind, "unix://#{shared_path}/tmp/sockets/puma.sock"

set :bundle_binstubs, nil
set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system', )

after 'deploy:publishing', 'deploy:restart'

namespace :puma do
  desc 'Create Directories for Puma Pids and Socket'
  task :make_dirs do
    on roles(:app) do
      execute "mkdir #{shared_path}/tmp/sockets -p"
      execute "mkdir #{shared_path}/tmp/pids -p"
    end
  end

  before :start, :make_dirs
end

namespace :deploy do

    task :check do
        on roles(:app) do
            upload! "config/application.yml", "#{shared_path}/config/application.yml", via: :scp
            upload! "config/database.yml", "#{shared_path}/config/database.yml", via: :scp
            upload! "config/puma.rb", "#{shared_path}/config/puma.rb", via: :scp
            set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/puma.rb', 'config/application.yml')
        end
    end

    # task :symlink do
    #   desc "Symlink application.yml to the release path"
    #     on roles(:app) do
    #         execute "ln -sf #{shared_path}/config/application.yml #{release_path}/config/application.yml"
    #     end
    # end
    task :restart do
        # invoke 'unicorn:legacy_restart'
    end
    
    task :printenv do 
        run "printenv"
    end
end

 
# namespace :deploy do
#   %w[start stop restart].each do |command|
#       if command == 'restart'
#           task :restart do
#               on primary roles :app do
#                   invoke 'unicorn:reload'
#               end
#               end
#           else
#           desc "#{command} unicorn server"
#           task command, roles: :app, except: {no_release: true} do
#             run "/etc/init.d/unicorn_#{application} #{command}"
#           end
#       end
#       end
 
#       task :setup_config, roles: :app do
#       sudo "ln -nfs #{current_path}/config/nginx.conf /etc/nginx/sites-enabled/#{application}"
#       sudo "ln -nfs #{current_path}/config/unicorn_init.sh /etc/init.d/unicorn_#{application}"
#       run "mkdir -p #{shared_path}/config"
#       put File.read("config/database.example.yml"), "#{shared_path}/config/database.yml"
#       puts "Now edit the config files in #{shared_path}."
#       end
#       after "deploy:setup", "deploy:setup_config"
 
#       task :symlink_config, roles: :app do
#       run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
#   end
#       after "deploy:finalize_update", "deploy:symlink_config"
 
#   desc "Make sure local git is in sync with remote."
#       task :check_revision, roles: :web do
#           unless `git rev-parse HEAD` == `git rev-parse origin/master`
#           puts "WARNING: HEAD is not the same as origin/master"
#           puts "Run `git push` to sync changes."
#           exit
#       end
#       end
#       before "deploy", "deploy:check_revision"
# end