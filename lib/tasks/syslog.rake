namespace :load do
  task :defaults do
    set :syslog_grep_pattern, ENV['pattern']
    set :syslog_all_logs, %w(y Y yes true 1).include?(ENV['all_logs'])
  end
end

namespace :syslog do
  desc <<-EOM
    Grep the syslog on all boxes for a specific pattern (cap production syslog:grep pattern=my_regex_pattern all_logs=y)
  EOM
  task :grep do
    syslogs_name =
      if fetch(:syslog_all_logs)
        '/var/log/syslog*'
      else
        '/var/log/syslog'
      end

    on release_roles :all do
      if fetch(:syslog_grep_pattern).to_s.strip != ''
        sudo 'zgrep', '-E', fetch(:syslog_grep_pattern), syslogs_name
      else
        fail 'No pattern specified, please use pattern=PATTERN'
      end
    end
  end
end
