namespace :maintenance do
  desc 'Show the maintenence page and return a 503 error for every new HTTP request.'
  task :begin do
    on release_roles :web do
      execute [
        "mkdir -p #{current_path}/public/system",
        "cp #{current_path}/public/inactive.maintenance.html #{current_path}/public/system/maintenance.html"
      ].join(' && ')
    end
  end

  desc 'Turn off the maintenance page and resume normal operations.'
  task :end do
    on release_roles :web do
      execute "rm -f #{current_path}/public/system/maintenance.html"
    end
  end
end
