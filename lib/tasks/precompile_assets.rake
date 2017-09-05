namespace :assets do
  include ElocalCapistrano::GitTools

  task :defaults do
    set :assets_path, 'public/assets/'
  end

  desc <<-DESC
    Precompile assets
  DESC
  task :precompile do
    run_locally do
      execute "rake assets:clean"
      execute "rake assets:precompile"
    end
  end

  desc <<-DESC
    Commit precompiled assets and push to github
  DESC
  task :push_assets do
    run_locally do
      execute :git, "add #{fetch(:assets_path)}"
      execute :git, "commit -m '[RELEASE][#{fetch(:rails_env)}] Precompile assets for #{fetch(:rails_env)}' #{fetch(:assets_path)}"
      execute :git, 'push origin master'
    end
  end
end
