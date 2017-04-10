namespace :deploy do
  namespace :webpack do
    def frontend_changed?
      %x(git diff #{ReleaseTag.latest} #{fetch(:fronted_path)}).length > 0
    end

    desc <<-DESC
      Check if a new frontend release is required and deploy to S3
    DESC
    task :release do
      on roles(:all) do
        if frontend_changed? || fetch(:force_webpack_release, false)
          info '[deploy:webpack] Creating new webpack release'
          invoke 'deploy:webpack:make_new_release'
        else
          info '[deploy:webpack] Skipping webpack release as no changes were detected in frontend directory'
        end
      end
    end

    desc <<-DESC
      create new webpack bundle and release
    DESC
    task :make_new_release do
      invoke 'deploy:webpack:install_dependencies'
      invoke 'deploy:webpack:bundle'
      invoke 'deploy:webpack:add_to_version_control'
    end

    desc <<-DESC
      Installs required javascript packages from Node Package Manager
    DESC
    task :install_dependencies do
      run_locally do
        execute 'yarn install --pure-lockfile'
      end
    end

    desc <<-DESC
      Compiles webpack bundle and uploads to S3
    DESC
    task :bundle do
      run_locally do
        execute 'yarn run build'
      end
    end

    desc <<-DESC
      Check in updated webpack manifest and S3 paths to git
    DESC
    task :add_to_version_control do
      run_locally do
        execute "git commit -m '[FRONTEND] Updated webpack bundle' #{fetch(:webpack_manifest_file)}"
      end
    end
  end
end
