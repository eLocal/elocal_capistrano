namespace :load do
  task :defaults do
    set :syslog_grep_pattern, ENV['pattern']
    set :syslog_all_logs, %w(y Y yes true 1).includes?(ENV['all_logs'])
  end
end

namespace :syslog do
  desc 'Grep the syslog for a pattern'
  task :grep do
    syslogs_name =
      if fetch(:all_logs)
        '/var/log/syslog*'
      else
        '/var/log/syslog'
      end

    on release_roles :all do
      if fetch(:pattern).to_s.strip != ''
        sudo "zgrep -E #{pattern} #{syslogs_name}"
      else
        fail 'No pattern specified, please use pattern=PATTERN'
      end
    end
  end
end
