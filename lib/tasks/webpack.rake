# frozen_string_literal: true

namespace :deploy do
  namespace :webpack do
    def frontend_changed?
      fronted_path = fetch(:fronted_path)
      frontend_changes = `git diff #{ReleaseTag.latest} #{fronted_path}`
      frontend_changes = frontend_changes.split.select { |str| str.include?(fronted_path) }.map { |str| str[2..-1] }.uniq

      frontend_changes_count = frontend_changes.count
      print_info(nil, "Changed files in #{fronted_path}: Total #{frontend_changes_count}:")
      frontend_changes.each { |frontend_change| print_info(nil, frontend_change) }

      frontend_changes_count.positive?
    end

    def force_webpack_release?
      fetch(:force_webpack_release, false) || %w(y Y yes true 1).include?(ENV['force_webpack_release'])
    end

    desc <<-DESC
      Check if a new frontend release is required and deploy to S3
    DESC
    task :release do |task|
      print_info(task, 'Check if a new frontend release is required and deploy to S3')

      print_info(task, "Check if #{fetch(:fronted_path)} changed since release #{ReleaseTag.latest}")
      new_webpack_release_needed = frontend_changed?

      unless new_webpack_release_needed
        print_info(task, 'Check if a Webpack release is forced')
        new_webpack_release_needed = force_webpack_release?
      end

      if new_webpack_release_needed
        print_info(task, 'Creating new webpack release')
        invoke 'deploy:webpack:make_new_release'
      else
        print_info(task, 'Skipping webpack release as no changes were detected in frontend directory')
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

  def print_info(task, str)
    on roles(:all) do
      info "[#{task&.name}] #{str}"
    end
  end
end
