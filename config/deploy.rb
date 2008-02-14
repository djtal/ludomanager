# This defines a deployment "recipe" that you can feed to capistrano
# (http://manuals.rubyonrails.com/read/book/17). It allows you to automate
# (among other things) the deployment of your application.


# =============================================================================
# REQUIRED VARIABLES
# =============================================================================
# You must always specify the application and repository for every recipe. The
# repository must be the URL of the repository you want this recipe to
# correspond to. The deploy_to path must be the path on each machine that will
# form the root of the application path.

set :application, "teamscore"
set :repository, "http://djserv.dyndns.org/svn/rails_stuff/applications/24gameday/"
set :keep_releases, '3'

# =============================================================================
# ROLES
# =============================================================================
# You can define any number of roles, each of which contains any number of
# machines. Roles might include such things as :web, or :app, or :db, defining
# what the purpose of each machine is. You can also specify options that can
# be used to single out a specific subset of boxes in a particular role, like
# :primary => true.

role :web, "djserv.org"
role :app, "djserv.org"
role :db,  "djserv.org", :primary => true


# =============================================================================
# OPTIONAL VARIABLES
# =============================================================================

set :deploy_to, "/var/www/virtual/djserv.org/teamscore" # defaults to "/u/apps/#{application}"
set :user, "vu2045"                  # defaults to the currently logged in user


# set :scm, :darcs               # defaults to :subversion
# set :svn, "/path/to/svn"       # defaults to searching the PATH
# set :darcs, "/path/to/darcs"   # defaults to searching the PATH
# set :cvs, "/path/to/cvs"       # defaults to searching the PATH
# set :gateway, "gate.host.com"  # default to no gateway

# =============================================================================
# SSH OPTIONS
# =============================================================================
# ssh_options[:keys] = %w(/path/to/my/key /path/to/another/key)
# ssh_options[:port] = 25

# =============================================================================
# TASKS
# =============================================================================
# Define tasks that run on all (or only some) of the machines. You can specify
# a role (or set of roles) that each task should be executed on. You can also
# narrow the set of servers to a subset of a role by specifying options, which
# must match the options given for the servers to select (like :primary => true)
desc "start the mongrel server"
task :spinner, :roles => :app do
  application_port = 8045 #get this from your friendly sysadmin
  run "mongrel_rails start -e production -p #{application_port} -d -c #{current_path}"
end

desc "Restart the app server"
task :restart, :roles => :app do
  begin
    run "cd #{current_path} && mongrel_rails restart"
  rescue RuntimeError => e
    puts e
    puts "Mongrel probably not running try spinner task"
  end
end

task :after_symlink, :roles => [:app, :db] do
  run "ln -nfs #{deploy_to}/#{shared_dir}/images #{deploy_to}/current/public/game_photos"
end
