# Capistrano::Configuration.instance.load do

  namespace :deploy do

    desc "Symlink configuration files to the config/ directory."
    task :symlink_shared_configuration do
      on roles(:app) do
        run <<-CMD
          if [ -d #{deploy_to}/shared/config ]; then
            cd #{deploy_to}/shared/config;
            for f in `ls -x`; do
              if [ -f #{release_path}/config/$f ]; then
                mv #{release_path}/config/$f #{release_path}/config/$f.orig;
              fi;
              ln -nfs #{deploy_to}/shared/config/$f #{release_path}/config/$f;
            done;
          fi;
        CMD
      end
    end
  end

# end
