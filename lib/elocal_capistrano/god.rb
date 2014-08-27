Capistrano::Configuration.instance.load do
  namespace :god do
    namespace :application do
      [:start, :stop, :restart].each do |t|
        task t, :roles => :app, except: { no_release: true } do
          sudo "god #{t} #{application}"
        end
      end
    end
  end
end
