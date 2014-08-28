Capistrano::Configuration.instance.load do
  set(:god_application_name) { application }
  namespace :god do
    [:start, :stop, :restart].each do |t|
      task t, :roles => :app, except: { no_release: true } do
        sudo "god #{t} #{god_application_name}"
      end
    end
  end
end
