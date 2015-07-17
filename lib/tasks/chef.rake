task :chef do
  on release_roles :all do
    sudo 'chef-client'
  end
end
