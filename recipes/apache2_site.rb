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


Chef::Log.info "skystack::apache2 preparing to add virtual hosts and document roots."

node["sites"].each do |site|

if site['config']['webserver'] == 'apache2'

  if site['config']['template']
    Chef::Log.info "skystack::apache2_site Using a different template #{site['config']['template']}"    
    virtual_host_template =  site['config']['template']
  else
    Chef::Log.info "skystack::apache2_site Setting up a Apache2 site" 
    virtual_host_template = "php_apache2_virtualhost.erb"
  end
     
  if site["ssl"] == "on"
      include_recipe "apache2::mod_ssl"
  end

  Chef::Log.info "skystack::apache2_site adding a virtual host for #{site["server_name"]} to the server"  
   web_app site["server_name"] do
    template "#{virtual_host_template}"
    docroot site["document_root"]
    server_name site["server_name"]

    if site["server_aliases"]
      server_aliases site["server_aliases"]
    end

    if site["ssl"] == "on"
     ssl "on"
     ssl_certificate_file site["ssl_certificate_file"]  
     ssl_certificate_key_file site["ssl_certificate_key_file"]
     ssl_ca_certificate_file site["ssl_ca_certificate_file"]
    end
    
    if site["domain_redirect"]
      domain_redirect site["domain_redirect"]
    end

    if site["permanent_redirect"]
      permanent_redirect site["permanent_redirect"]
    end

    port site["port"]
   end
  
  Chef::Log.info "skystack::apache2_site adding our default landing page to #{site["document_root"]}"
   directory site["document_root"] do
     owner "www-data"
     group "www-data"
     mode "0755"
     action :create
     recursive true
   end

  #cookbook_file "#{site["document_root"]}/index.html" do
  #  source "index.html"
  #  mode 0755
  # owner "www-data"
  #  group "www-data"
  #  action :create_if_missing
  #  only_if do ! File.exists?("#{site["document_root"]}/index.php") end
  # end
      
   if site['config']["enable"].nil?   
      apache_site site["server_name"] do
        enable false
      end
   end
  
  if ! site['directories'].nil?
    site['directories'].each do |dir|
      directory "#{dir['path']}" do
        mode 00755
        action :create
        recursive dir['recursive']
      end
    end
  end  

  if ! site['symlinks'].nil?
    site['symlinks'].each do |sym|
      link "#{sym['from']}" do
        to "#{sym['to']}"
      end
    end
  end 

  if ! site['cache_server'].nil?

    if site['cache_server']['listen_port'] != 80
      node.set['varnish']['listen_port'] = site['cache_server']['listen_port']
    end
    
    node.set["varnish"]['backend_port'] = site['port']
    
    include_recipe "varnish"
  
  end

  service "apache2" do
    action :restart
  end

end

end
