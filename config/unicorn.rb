application = "ludomanager"
environment = ENV['RACK_ENV'] || ENV['RAILS_ENV'] || 'production'

app_path = "/home/#{application}/app"
bundle_path = "#{app_path}/vendor/bundle"
# Set the working application directory
# working_directory "/path/to/your/app"
working_directory "#{app_path}"

preload_app true

# Unicorn PID file location
# pid "/path/to/pids/unicorn.pid"
pid "#{app_path}/tmp/pids/unicorn.pid"

# Path to logs
stderr_path "#{app_path}/log/unicorn.log"
stdout_path "#{app_path}/log/unicorn.err.log"

# Unicorn socket
listen "/tmp/unicorn.ludomanager.sock"

# Helps ensure the correct unicorn binary is used when upgrading with USR2
# See http://unicorn.bogomips.org/Sandbox.html
Unicorn::HttpServer::START_CTX[0] = "#{bundle_path}/bin/unicorn"

# REE-friendly
if GC.respond_to?(:copy_on_write_friendly=)
  GC.copy_on_write_friendly = true
end

# Number of processes
worker_processes 2

# Time-out
timeout 30

before_fork do |server, worker|
  ActiveRecord::Base.connection.disconnect! if defined?(ActiveRecord::Base)
end

after_fork do |server, worker|
  if defined?(ActiveRecord::Base)
    config = ActiveRecord::Base.configurations[Rails.env]
    config['reaping_frequency'] = ENV['DB_REAP_FREQ'] || 10 # seconds
    config['pool']            =   ENV['DB_POOL'] || 2
    ActiveRecord::Base.establish_connection
  end
end

