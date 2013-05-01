
if node['deployments']

  node['deployments'].each do |app|

	if app['config']['strategy'] == 'archive'

		execute "#{app['fetch_archive_command']}" do
			only_if do ! File.exists?("#{app['archive_path']}") end
		end

		execute "unzip #{app['archive_path']}" do 
			cwd "#{app['release_path']}"
			only_if do File.exists?("#{app['archive_path']}") end
		end

		execute "rm #{app['archive_path']}" do 
			only_if do File.exists?("#{app['archive_path']}") end
		end

		# lets rename current symlink to rollback
		if ! app['rollback_path'].nil?
			execute "mv #{app['symlink']} #{app['rollback']}" do 
				only_if do File.exists?("#{app['symlink']}") end
			end
		end

		execute "ln -s #{app['base_path']}/releases/`ls -a #{app['base_path']}/releases | grep #{app['name']}` current" do
			cwd "#{app['base_path']}"
		end

	end

  end

end