namespace :load do
  task :defaults do
    set :owned_by_user, 'app'
    set :owned_by_group, 'deploy'
  end
end

namespace :deploy do
  task :set_app_ownership do
    on release_roles(:all) do
      within release_path do
        sudo "chown -R #{fetch(:owned_by_user)}:#{fetch(:owned_by_group)} ."
      end
    end
  end
end
