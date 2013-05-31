# Cookbook Name:: skystack
# Recipe:: skystack::sites
# Copyright:: 2010, Skystack Limited.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#


package "haproxy" do
  action :install
end

template "/etc/default/haproxy" do
  source "haproxy-default.erb"
  owner "root"
  group "root"
  mode 0644
end

service "haproxy" do
  supports :restart => true, :status => true, :reload => true
  action [:enable, :start]
end

if node['lb']['glb'] == true

	directory "/etc/haproxy/subnets" do
	 mode 00755
	 action :create
	 recursive true
	end

	execute "wget http://glb.skystack.com.s3.amazonaws.com/subnets.zip" do 
		cwd "/etc/haproxy/subnets"
	end

	execute "unzip subnets.zip" do 
		cwd "/etc/haproxy/subnets"
		only_if do File.exists?("/etc/haproxy/subnets/subnets.zip") end
	end

	template "/etc/haproxy/haproxy.cfg" do
	  source "glb.haproxy.cfg.erb"
	  owner "root"
	  group "root"
	  mode 0644
	  notifies :restart, "service[haproxy]"
	end

else	

	template "/etc/haproxy/haproxy.cfg" do
	  source "haproxy.cfg.erb"
	  owner "root"
	  group "root"
	  mode 0644
	  notifies :restart, "service[haproxy]"
	end
	
end
