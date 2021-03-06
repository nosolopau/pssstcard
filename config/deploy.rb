# config valid only for Capistrano 3.1
lock '3.2.1'

set :application, 'pssstcard'
set :repo_url, 'git@github.com:nosolopau/pssstcard.git'
set :user, 'deploy'
set :whenever_identifier, ->{ "#{fetch(:application)}_#{fetch(:stage)}" }

set :deploy_to, "/home/#{fetch(:user)}/public_html/#{fetch(:application)}_#{fetch(:stage)}"
set :deploy_via, 'remote_cache'
set :rails_env, 'production'

set :linked_dirs, %w{log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}
set :linked_files, %w{.env newrelic.yml}
set :unicorn_binary, "bundle exec unicorn"
set :unicorn_config, "#{release_path}/config/unicorn.rb"
set :unicorn_pid, "#{shared_path}/tmp/pids/unicorn.pid"

namespace :deploy do
  task :start do
    on roles(:app), in: :sequence, wait: 5 do
      execute "cd #{release_path} && #{fetch(:unicorn_binary)} -c #{fetch(:unicorn_config)} -E production -D"
    end
  end

  task :stop do
    on roles(:app), in: :sequence, wait: 5 do
      execute "kill `cat #{fetch(:unicorn_pid)}`"
    end
  end

  task :graceful_stop do
    on roles(:app), in: :sequence, wait: 5 do
      execute "kill -s QUIT `cat #{fetch(:unicorn_pid)}`"
    end
  end

  task :reload do
    on roles(:app), in: :sequence, wait: 5 do
      execute "kill -s USR2 `cat #{fetch(:unicorn_pid)}`"
    end
  end

  task :restart
  after 'deploy:restart', 'deploy:reload'

  after 'deploy', 'deploy:reload'
end

after 'deploy:publishing', 'deploy:restart'
