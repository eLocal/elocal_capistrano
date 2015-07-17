namespace :ec2 do
  task :ssh do
    index = ENV['server'].to_i
    server = release_roles(:all)[index]
    if server
      exec "ssh #{server.user}@#{server.hostname}"
    else
      fail "Could not find a server to SSH to at index #{index}."
    end
  end
end
