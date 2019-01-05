namespace :load do
  task :defaults do
    set :versions_path, 'config/versions.yml'
  end
end

namespace :git do
  namespace :tagging do
    include ElocalCapistrano::GitTools

    desc <<-DESC
      Make sure the working directory is clean and on right branch
    DESC
    task :check_local do
      run_locally do
        unless working_directory_copasetic?
          error 'Cannot continue because working directory is not clean'
          raise 'Working directory not clean'
        end
      end
    end

    desc <<-DESC
      Create a new tag for current release and set current revision
    DESC
    task :tag_release do
      run_locally do
        unless ENV['SKIP_GIT_TAGGING'].to_s.upcase == 'Y'
          tag = increment_patch_version
          update_versions_file(tag)
          execute :git, "add #{fetch(:versions_path)}"
          execute :git, "commit -m '[RELEASE][#{fetch(:rails_env)}] Update release tag for #{fetch(:rails_env)} to #{tag}' #{fetch(:versions_path)}"
          execute :git, 'push origin master'
          execute :git, "tag #{tag}"
          execute :git, "push origin #{tag}"
          set :branch, tag.to_s
        else
          set :branch, ReleaseTag.current('staging').to_s
        end
      end
    end

    desc <<-DESC
      Use previous staging tag for release
    DESC
    task :use_release do
      run_locally do
        staging_tag = ReleaseTag.current('staging')
        current_tag = ReleaseTag.current(fetch(:stage).to_s)
        if staging_tag != current_tag
          update_versions_file(staging_tag)
          execute :git, "add #{fetch(:versions_path)}"
          execute :git, "commit -m '[RELEASE][#{fetch(:rails_env)}] Update release tag for #{fetch(:rails_env)} to #{staging_tag}' #{fetch(:versions_path)}"
          execute :git, 'push origin master'
        else
          puts 'Current version up-to-date. No update needed'
        end
        set :branch, staging_tag.to_s
      end
    end

    desc <<-DESC
      Prints out current environment release information
    DESC
    task :current_release do
      run_locally do
        puts "#{fetch(:stage)}: #{ReleaseTag.current(fetch(:stage).to_s)}"
      end
    end
  end
end
