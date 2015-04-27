# Capistrano::Configuration.instance.load do
#   set(:pattern, '')
#   set(:all_logs, false)

#   namespace :syslog do
#     desc "Grep the sys"
#     task :grep do
#       syslogs_name = if all_logs
#         '/var/log/syslog*'
#       else
#         '/var/log/syslog'
#       end

#       if pattern.to_s.strip != ''
#         sudo "zgrep -E #{pattern} #{syslogs_name}"
#       else
#         fail "No pattern specified, please use -s pattern=PATTERN"
#       end
#     end
#   end
# end
