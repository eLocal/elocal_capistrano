Capistrano::Configuration.instance.load do
  namespace :puma do
    namespace :upstart do
      %w(start stop status).each do |t|
        desc "Perform #{t} of the api_puma service"
        task t, roles: :app, except: { no_release: true } do
          sudo "#{t} api_puma"
        end
      end

      desc 'Perform a restart of the api_puma service'
      task :restart, roles: :app, except: { no_release: true } do
        run <<-CMD
          pid=`status api_puma | grep -o -E '[0-9]+'`;
          if [ -z $pid ]; then
            sudo start api_puma;
          else
            kill -USR1 $pid;
          fi
        CMD
      end
    end
  end
end
