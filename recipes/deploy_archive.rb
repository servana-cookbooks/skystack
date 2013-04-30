
if deploy['config']['strategy'] == 'archive'

	execute "#{deploy['fetch_archive_command']}" do
		only_if do ! File.exists?("#{deploy['archive_path']}") end
	end

	execute "unzip #{deploy['archive_path']}" do 
		cwd "#{deploy['release_path']}"
		only_if do File.exists?("#{deploy['archive_path']}") end
	end

	execute "rm #{deploy['archive_path']}" do 
		only_if do File.exists?("#{deploy['archive_path']}") end
	end

	# lets rename current symlink to rollback
	if ! deploy['rollback_path'].nil?
		execute "mv #{deploy['symlink']} #{deploy['rollback']}" do 
			only_if do File.exists?("#{deploy['symlink']}") end
		end
	end

	execute "ln -s #{deploy['base_path']}/releases/`ls -a #{deploy['base_path']}/releases | grep #{deploy['name']}` current" do
		cwd "#{deploy['base_path']}"
	end

end
