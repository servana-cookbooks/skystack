
execute "curl -L -o /opt/skystack/downloads/github_arch.zip -H \"Authorization: token #{node['github']['token']}\" #{node['github']['url']}" do
	only_if do ! File.exists?("/opt/skystack/downloads/github_arch.zip") end
end

execute "unzip /opt/skystack/downloads/github_arch.zip" do 
	cwd "node['github']['path']/releases"
	only_if do File.exists?("/opt/skystack/downloads/github_arch.zip") end
end

execute "rm /opt/skystack/downloads/github_arch.zip" do 
	only_if do File.exists?("/opt/skystack/downloads/github_arch.zip") end
end

# lets rename current symlink to rollback
if ! node['github']['rollback'].nil?
	execute "mv #{node['github']['symlink']} #{node['github']['rollback']}" do 
		only_if do File.exists?("#{node['github']['symlink']}") end
	end
end

execute "ln -s node['github']['path']/releases/`ls -a #{node['github']['path']}/releases | grep #{node['github']['name']}` current" do
	cwd "node['github']['path']"
end

