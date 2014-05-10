
set :application, 'ludomanager'
set :repository, 'git@github.com:djtal/ludomanager.git'

server '188.226.131.84', :app
set :user,                    :djtal
set :bundle_path, "#{deploy_to}/vendor/bundle/gems"
