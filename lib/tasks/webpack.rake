# frozen_string_literal: true

namespace :deploy do
  namespace :webpack do
    def frontend_changed?
      fronted_path = fetch(:fronted_path)
      frontend_changes = `git diff #{ReleaseTag.latest} #{fronted_path}`
      frontend_changes = frontend_changes.split.select { |str| str.include?(fronted_path) }.map { |str| str[2..-1] }.uniq
      frontend_changes_count = frontend_changes.count

      print_info(nil, "Changed files in #{fronted_path}: Total #{frontend_changes_count}#{':' if frontend_changes_count.positive?}")
      frontend_changes.each { |frontend_change| print_info(nil, "--- #{frontend_change}") }

      frontend_changes_count.positive?
    end

    def force_webpack_release?
      forced = fetch(:force_webpack_release, false) || %w(y yes true 1).include?(ENV['force_webpack_release'].to_s.downcase)

      print_info(nil, "force_webpack_release: #{forced}")

      forced
    end

    desc <<-DESC
      Check if a new frontend release is required
    DESC
    task :release do |task|
      print_info(task, 'Checking if a new frontend release is required')

      print_info(task, "Checking if #{fetch(:fronted_path)} changed since release #{ReleaseTag.latest}")
      new_webpack_release_needed = frontend_changed?

      unless new_webpack_release_needed
        print_info(task, 'Checking if a Webpack release is forced')
        new_webpack_release_needed = force_webpack_release?
      end

      if new_webpack_release_needed
        invoke 'deploy:webpack:make_new_release'
      else
        print_info(task, 'Skipping webpack release as no changes were detected in frontend directory')
      end
    end

    desc <<-DESC
      Create a new Webpack bundle release
    DESC
    task :make_new_release do |task|
      print_info(task, 'Creating a new Webpack bundle release')

      invoke 'deploy:webpack:install_dependencies'
      invoke 'deploy:webpack:bundle'
      invoke 'deploy:webpack:add_to_version_control'
    end

    desc <<-DESC
      Install required JS packages from NPM
    DESC
    task :install_dependencies do |task|
      print_info(task, 'Installing required JS packages from NPM')

      run_locally do
        execute 'yarn install --pure-lockfile'
      end
    end

    desc <<-DESC
      Compile a new webpack bundle release and upload to S3
    DESC
    task :bundle do |task|
      print_info(task, 'Compiling a new webpack bundle release and uploading to S3')

      run_locally do
        execute 'yarn run build'
      end
    end

    desc <<-DESC
      Commit to git the updated Webpack manifest with its S3 paths
    DESC
    task :add_to_version_control do |task|
      webpack_manifest_file = fetch(:webpack_manifest_file)

      print_info(task, "Committing to git the updated Webpack manifest #{webpack_manifest_file} with its S3 paths")

      webpack_manifest_file_changed = `git diff #{webpack_manifest_file}`.length.positive?

      if webpack_manifest_file_changed
        run_locally do
          execute "git commit -m '[FRONTEND] Updated webpack bundle' #{webpack_manifest_file}"
        end
      else
        print_info(task, "Skipping commit to git since no changes have been detected for #{webpack_manifest_file}")
      end
    end
  end

  def print_info(task, str)
    on roles(:all) do
      info "[#{task&.name || '-'}] #{str}"
    end
  end
end
