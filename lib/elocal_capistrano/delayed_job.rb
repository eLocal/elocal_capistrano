# Capistrano::Configuration.instance.load do
#   set(:delayed_job_application_name) { "#{application}_delayed_job" }
#   namespace :delayed_job do
#     namespace :upstart do
#       %w(start stop status).each do |t|
#         desc "Perform #{t} of the delayed_job service"
#         task t, roles: :app, except: { no_release: true } do
#           sudo "#{t} #{delayed_job_application_name}"
#         end
#       end
#       desc 'Perform a restart of the application puma service'
#       task :restart, roles: :app, except: { no_release: true } do
#         run <<-CMD.strip
#           pid=`status #{delayed_job_application_name} | grep -o -E '[0-9]+'`; if [ -z $pid ]; then sudo start #{delayed_job_application_name}; else sudo restart #{delayed_job_application_name}; fi
#         CMD
#       end
#     end
#   end
# end
