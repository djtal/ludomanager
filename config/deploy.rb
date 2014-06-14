require "whenever/capistrano"
set :whenever_command, "bundle exec whenever"


namespace :rails do
  namespace :assets do
    namespace :precompile do
      task :if_changed do
        false
      end

      task :precompile do
        # do nothing since we don't have asset pipeline in rails 2.3
      end

      task :default do
        # do nothing since we don't have asset pipeline in rails 2.3
      end
    end
  end
end
