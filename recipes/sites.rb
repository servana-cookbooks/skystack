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

app = node.run_state[:current_app]

Chef::Log.info "skystack::apache2 preparing to add virtual hosts and document roots."


node["sites"].each do |site|

  if site['config']['webserver']
    case site['config']['webserver']
      when "apache2"
        webserver = "apache"
        virtual_host_template = "php_apache2_virtualhost.erb"
      when "nginx"
        webserver = "nginx"
        virtual_host_template = "php_nginx_virtualhost.erb"
    end
  end

  if site["ssl"] == 1
    include_recipe "apache2::mod_ssl"
  end

  if !site["port"].nil?
    node.set["#{webserver}"]['listen_ports'] = site["port"]
  end

  Chef::Log.info "skystack::sites adding a virtual host for #{site["server_name"]} to the server"
  web_app site["server_name"] do
    template "#{virtual_host_template}"
    docroot site["document_root"]
    server_name site["server_name"]
    server_aliases site["server_aliases"]
  end


  Chef::Log.info "skystack::sites creating in #{site["document_root"]}"
  directory site["document_root"] do
    owner "www-data"
    group "www-data"
    mode "0755"
    action :create
    recursive true
  end


   Chef::Log.info "skystack::sites adding our default landing page to #{site["document_root"]}"
   cookbook_file "#{site["document_root"]}/index.php" do
    source "index.php"
    mode 0755
    owner "www-data"
    group "www-data"
    action :create_if_missing
   end

  if site["enable"].nil?
    apache_site site["server_name"] do
      enable false
    end
  end
  
  service site['config']['webserver'] do
    action :restart
  end

end

Chef::Log.info "skystack::sites disabling default Apache site."
apache_site "000-default" do
  enable false
end



