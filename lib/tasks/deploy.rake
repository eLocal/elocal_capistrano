namespace :load do
  task :defaults do
    set :owned_by_user, 'app'
    set :owned_by_group, 'deploy'
  end
end

# For our rails applications, the actual ruby code is run
# by a different user than our deploy user. We want to make sure the directory
# permissions are set appropriately
namespace :deploy do
  task :set_app_ownership do
    on release_roles(:all) do
      within release_path do
        sudo "chown -R #{fetch(:owned_by_user)}:#{fetch(:owned_by_group)} ."
      end
    end
  end
end
