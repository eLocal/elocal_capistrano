namespace :load do
  task :defaults do
    set :puma_application_name, -> { "#{fetch(:application)}_puma" }
    set :delayed_job_application_name, -> { "#{fetch(:application)}_delayed_job" }
    set :shoryuken_application_name, -> { "#{fetch(:application)}_shoryuken" }
    set :sidekiq_application_name, -> { "#{fetch(:application)}_sidekiq" }
    set :delayed_job_release_role, -> { :app }
    set :puma_release_role, -> { :app }
    set :shoryuken_release_role, -> { :app }
    set :sidekiq_release_role, -> { :app }
  end
end

namespace :service do
  namespace :puma do
    %w(reload start stop status).each do |t|
      desc "Perform #{t} of the puma service"
      task t do
        on release_roles fetch(:puma_release_role) do
          Array(fetch(:puma_application_name)).each do |app_name|
            sudo :service, app_name, t
          end
        end
      end
    end

    desc 'Perform a restart of the application puma service'
    task :restart do
      on release_roles fetch(:puma_release_role) do
        Array(fetch(:puma_application_name)).each do |app_name|
          execute <<-CMD.strip
            pid=`systemctl show -p MainPID #{app_name}.service | grep -o -E '[0-9]+'`; if [ "$pid" -eq "0" ] || [ -z $pid ]; then sudo service #{app_name} start; else sudo service #{app_name} reload; fi
          CMD
        end
      end
    end

    desc 'Perform a start/stop not a reload of the application puma service'
    task :hard_restart do
      on release_roles fetch(:puma_release_role) do
        Array(fetch(:puma_application_name)).each do |app_name|
          sudo :service, app_name, :restart
        end
      end
    end
  end

  %i(delayed_job sidekiq shoryuken).each do |task_name|
    namespace task_name do
      %w(start stop status).each do |t|
        desc "Perform #{t} of the #{task_name} service"
        task t do
          on release_roles fetch(:"#{task_name}_release_role") do
            sudo :service, fetch(:"#{task_name}_application_name"), t
          end
        end
      end

      desc 'Perform a restart of the application #{task_name} service'
      task :restart do
        on release_roles fetch(:"#{task_name}_release_role") do
          job_name = fetch(:"#{task_name}_application_name")
          execute <<-CMD.strip
            pid=`systemctl show -p MainPID #{job_name} | grep -o -E '[0-9]+'`; if [ "$pid" -eq "0" ] || [ -z $pid ]; then sudo service #{job_name} start; else sudo service #{job_name} restart; fi
          CMD
        end
      end
    end
  end
end
