
if deploy['config']['strategy'] == 'repo'

	if app['force']
	   deploy_action = app['force']
	 else
	   deploy_action = :deploy
	 end

	 if app['symlinks']
	    app_symlinks = {}

	    app['symlinks'].each do |link|
	      app_symlinks[link['from']] = link['to']
	    end
	 else  
	      app_symlinks = {}
	 end

	deploy_revision app['name'] do
	    environment({"HOME" => app['home']})
	    revision app['revision']
	    repository app['repository']
	    user app['owner']
	    group app['group']
	    deploy_to app['path']
	    action deploy_action
	    git_ssh_wrapper app['ssh_wrapper']
	    shallow_clone true
	    purge_before_symlink.clear
	    create_dirs_before_symlink.clear
	    symlinks.clear
	    symlink_before_migrate.clear
	    restart_command "/etc/init.d/apache2 restart"
	end

end