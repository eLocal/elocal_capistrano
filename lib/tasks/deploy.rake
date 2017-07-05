namespace :load do
  task :defaults do
    set :owned_by_user, 'app'
    set :owned_by_group, 'deploy'
    set :release_paths_to_be_owned_by_app, '.'
    set :shared_paths_to_be_owned_by_app, 'log pids tmp'
  end
end

# For our rails applications, the actual ruby code is run
# by a different user than our deploy user. We want to make sure the directory
# permissions are set appropriately
namespace :deploy do
  task :set_app_ownership do
    on release_roles(:all) do
      within release_path do
        paths = Array(fetch(:release_paths_to_be_owned_by_app)).join(' ')
        sudo "chown -R #{fetch(:owned_by_user)}:#{fetch(:owned_by_group)} #{paths}"
      end
    end
    on release_roles(:all) do
      within shared_path do
        paths = Array(fetch(:shared_paths_to_be_owned_by_app)).join(' ')
        sudo "chown -R #{fetch(:owned_by_user)}:#{fetch(:owned_by_group)} #{paths}"
      end
    end
  end
end
