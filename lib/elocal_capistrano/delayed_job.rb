Capistrano::Configuration.instance.load do
  set(:delayed_job_application_name) { "#{application}_delayed_job" }
  namespace :delayed_job do
    namespace :upstart do
      %w(restart start stop status).each do |t|
        desc "Perform #{t} of the delayed_job service"
        task t, roles: :app, except: { no_release: true } do
          sudo "#{t} #{delayed_job_application_name}"
        end
      end
    end
  end
end
