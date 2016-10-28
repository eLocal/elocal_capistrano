task :chef do
  on release_roles :all do
    execute <<-CMD.strip
      if [ -x /usr/local/bin/run-bootstrapped-chef ]; then sudo run-bootstrapped-chef; else sudo chef-client; fi
    CMD
  end
end
