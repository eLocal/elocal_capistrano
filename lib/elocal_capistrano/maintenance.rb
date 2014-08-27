Capistrano::Configuration.instance.load do
  namespace :maintenance do
    desc "Show the maintenence page and return a 503 error for every new HTTP request."
    task :begin, :roles => :app do
      run "mkdir -p #{current_path}/public/system && cp #{current_path}/public/503.html #{current_path}/public/system/503.html"
    end

    desc "Turn off the maintenance page and resume normal operations."
    task :end, :roles => :app do
      run "rm -f #{current_path}/public/system/503.html"
    end
  end
end
