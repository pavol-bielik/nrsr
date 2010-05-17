set :application, "nrsr"
set :repository,  "git://github.com/pavol-bielik/nrsr.git"
set :deploy_via, :remote_cache
set :branch, "master"

#ssh_options[:forward_agent] = true
ssh_options[:keys] = [File.join(ENV["HOME"], "sshkey", "opensshprivatekey")]

set :scm, :git
#set :scm_passphrase, "4peaceworld"
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

set :deploy_to, "~/#{application}"

role :web, 'relax.fiit.stuba.sk'                          # Your HTTP server, Apache/etc
role :app, 'relax.fiit.stuba.sk'                          # This may be the same as your `Web` server
role :db,  'relax.fiit.stuba.sk', :primary => true        # This is where Rails migrations will run

set :user, 'bielik'
set :use_sudo, false

# If you are using Passenger mod_rails uncomment this:
# if you're still using the script/reapear helper you will need
# these http://github.com/rails/irs_process_scripts

# namespace :deploy do
#   task :start do ; end
#   task :stop do ; end
#   task :restart, :roles => :app, :except => { :no_release => true } do
#     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
#   end
# end