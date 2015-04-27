# Capistrano::Configuration.instance.load do
#   set(:puma_application_name) { "#{application}_puma" }
#   namespace :puma do
#     namespace :upstart do
#       %w(reload start stop status).each do |t|
#         desc "Perform #{t} of the _puma service"
#         task t, roles: :app, except: { no_release: true } do
#           sudo "#{t} #{puma_application_name}"
#         end
#       end

#       desc 'Perform a restart of the application puma service'
#       task :restart, roles: :app, except: { no_release: true } do
#         Array(puma_application_name).each do |app_name|
#           run <<-CMD.strip
#             pid=`status #{app_name} | grep -o -E '[0-9]+'`; if [ -z $pid ]; then sudo start #{app_name}; else sudo reload #{app_name}; fi
#           CMD
#         end
#       end
#     end
#   end
# end
