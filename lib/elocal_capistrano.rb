# Load any pertinent libraries
Dir["#{File.expand_path('..', __FILE__)}/**/*.rb"].each { |path| require path }

# Load capistrano rake tasks
Dir["#{File.expand_path('..', __FILE__)}/tasks/*.rake"].each { |path| load path }
