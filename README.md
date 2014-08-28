# Elocal Capistrano

A bunch of handy [Capistrano 2.0](https://github.com/capistrano/capistrano/wiki) tasks.

## Usage

### Chef

    cap chef

Runs chef-client on all servers.

### Delayed Job

    cap delayed_job:upstart:start
    cap delayed_job:upstart:restart
    cap delayed_job:upstart:stop

Start/stop/restart a delayed job process using upstart.  You can change the name of the task with the **delayed\_job\_application_name** variable.

    set(:delayed_job_application_name, 'foobar')

By default the **#{application}\_delayed\_job** is used.


Generally, this will be hooked in like:

    %w(start stop restart).each do |st|
      after "deploy:#{st}", "delayed_job:upstart:#{st}"
    end

### Deployment Utilities

    cap deploy:symlink_shared_configuration

This will find files in the directory #{deploy_to}/shared/config and link them in to the release path using the basic logic.

    ln -nfs #{deploy_to}/shared/config/$f #{release_path}/config/$f

Generally, this will be hooked in with an after callback.

    after "bundle:install", "deploy:symlink_shared_configuration"

### God

    cap god:start
    cap god:restart
    cap god:stop

Start/stop/restart a god process using.  You can change the name of the task with the **god\_application_name** variable.

    set(:god_application_name, 'foobar')

By default, the application name is used.

Generally, this will be hooked in like:

    %w(start stop restart).each do |st|
      after "deploy:#{st}", "god:#{st}"
    end

### Maintenance

    cap maintenance:begin
    cap maintenance:end

Creates a HTML page at **public/system/503.html**.  We rely on Nginx to check for that file and display it for all requests if present.

### Puma

    cap puma:upstart:start
    cap puma:upstart:restart
    cap puma:upstart:stop

Start/stop/restart a puma process using upstart.  You can change the name of the task with the **puma\_application_name** variable.

    set(:puma_application_name, 'foobar')

By default the **#{application}\_puma** is used.

Generally, this will be hooked in like:

    %w(start stop restart).each do |st|
      after "deploy:#{st}", "puma:upstart:#{st}"
    end

### Syslog

    cap syslog:grep -s pattern=abc -s all_logs=true

Utility to grep syslog for a specific pattern.

* **pattern** - The pattern to match on.  Regular expressions are used.  This is required.
* **all_logs** - If true, all syslogs will be search.  If false or unset, only the current log is searched.

## Installation

Add this line to your application's Gemfile:

    gem 'elocal_capistrano'

And then execute:

    $ bundle install

In your Capfile add

    require 'elocal_capistrano'


## Contributing

1. Fork it ( https://github.com/[my-github-username]/elocal_capistrano/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
