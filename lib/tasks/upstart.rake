namespace :load do
  task :defaults do
    set :puma_application_name, -> { "#{fetch(:application)}_puma" }
    set :delayed_job_application_name, -> { "#{fetch(:application)}_delayed_job" }
  end
end

namespace :upstart do
  namespace :puma do
    %w(reload start stop status).each do |t|
      desc "Perform #{t} of the puma service"
      task t do
        on release_roles :app do
          Array(fetch(:puma_application_name)).each do |app_name|
            sudo t, app_name
          end
        end
      end
    end

    desc 'Perform a restart of the application puma service'
    task :restart do
      on release_roles :app do
        Array(fetch(:puma_application_name)).each do |app_name|
          execute <<-CMD.strip
            pid=`status #{app_name} | grep -o -E '[0-9]+'`; if [ -z $pid ]; then sudo start #{app_name}; else sudo reload #{app_name}; fi
          CMD
        end
      end
    end

    desc 'Perform a start/stop not a reload of the application puma service'
    task :hard_restart do
      on release_roles :app do
        Array(fetch(:puma_application_name)).each do |app_name|
          sudo :restart, app_name
        end
      end
    end
  end

  namespace :delayed_job do
    %w(start stop status).each do |t|
      desc "Perform #{t} of the delayed_job service"
      task t do
        on release_roles :app do
          sudo t, fetch(:delayed_job_application_name)
        end
      end
    end

    desc 'Perform a restart of the application puma service'
    task :restart do
      on release_roles :app do
        dj_name = fetch(:delayed_job_application_name)
        execute <<-CMD.strip
          pid=`status #{dj_name} | grep -o -E '[0-9]+'`; if [ -z $pid ]; then sudo start #{dj_name}; else sudo restart #{dj_name}; fi
        CMD
      end
    end
  end
end
