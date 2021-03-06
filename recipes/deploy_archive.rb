
if node['deployments']

  node['deployments'].each do |app|

	if app['config']['strategy'] == 'archive' && app['config']['do_deploy'] == true

		directory "#{app['deploy_path']}" do
		 mode 00755
		 action :create
		 recursive true
		end

		directory "#{app['shared_path']}" do
		 mode 00755
		 action :create
		 recursive true
		end

		execute "#{app['fetch_archive_command']}" do
			only_if do ! File.exists?("#{app['archive_path']}") end
		end

		execute "unzip -o #{app['archive_path']}" do 
			cwd "#{app['deploy_path']}"
			only_if do File.exists?("#{app['archive_path']}") end
		end

		execute "rm #{app['archive_path']}" do 
			only_if do File.exists?("#{app['archive_path']}") end
		end

		if File.exist?("#{app['rollback_path']}")
			execute "rm #{app['rollback_path']}" do
				cwd "#{app['base_path']}"
			end
		end

		# lets rename current symlink to rollback
		if ! app['rollback_path'].nil?
			execute "mv #{app['symlink']} #{app['rollback_path']}" do 
				only_if do File.symlink?("#{app['symlink']}") end
			end
		end

		if ! File.symlink?("#{app['base_path']}/current")
			
			execute "rm -rf #{app['base_path']}/current" do
				cwd "#{app['base_path']}"
			end

		end

		execute "ln -s #{app['base_path']}/releases/`ls -lUt #{app['base_path']}/releases | head -2 | tail -1| awk '{print $9}'` current" do
			cwd "#{app['base_path']}"
		end

	end

  end

end