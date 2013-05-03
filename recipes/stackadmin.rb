# Cookbook Name:: skystack
# Recipe:: skystack::stackadmin
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
  include_recipe "users"

  if File.exists?("/opt/skystack/etc/userdata.conf")

    File.open('/opt/skystack/etc/userdata.conf').each_line{ |s|

      config = s.split("=")
     
      if config[0] == "API_USER"
        ApiUser = config[1]
      end

      if config[0] == "API_TOKEN"
        ApiToken = config[1]
      end

      if config[0] == "STACKADMIN_PUB"
        StackAdminHref = config[1]
      end

       if config[0] == "STACKADMIN_LOGIN"
        StackAdminLogin = config[1]
      end
    }

  end

  if StackAdminLogin && StackAdminHref && ApiToken && ApiUser

    Chef::Log.info "skystack::stackadmin creating a stackadmin called #{StackAdminLogin}"

    g = {}
    g['name'] = "sys-admin"

    u = {}

    u['ssh_keys'] = http_request "get public key" do
      action :get
      url StackAdminHref
      headers({"AUTHORIZATION" => "Basic #{Base64.encode64("#{ApiUser}:#{ApiToken}")}"})
    end

    u['username']= StackAdminLogin
    u['home'] = true
    u['comment'] = "First StackAdmin user"
    u['is_admin'] = true
    u['grant_sudo'] = true

    if u['home']
        home_dir = "/home/#{u['username']}"
    elsif u['home_dir']
        home_dir = "#{u['home_dir']}"
    end

    if home_dir
        manage_home = true
    else 
        manage_home = false
    end

    if u['shell']
        user_shell = u['shell']
    else
        user_shell = "#{node['user']['defaults']['shell']}"
    end

    user u['username'] do
      shell user_shell
      comment "#{u['comment']}"
      supports :manage_home => "#{manage_home}"
      home "#{home_dir}"
    end
    
    directory "#{home_dir}/.ssh" do
      owner u['username']
      group u['username']
      mode "0700"
    end

    if u['ssh_keys']

      template "#{home_dir}/.ssh/authorized_keys" do
       source "authorised_keys.erb"
       owner u['username']
       group u['username']
       mode "0600"
       variables :ssh_keys => u['ssh_keys']
      end

    end
    
    if u['is_admin']
      group "sys-admin" do
        action :modify
        members ["#{u['username']}"]
        append true
      end
    end

   if u['grant_sudo']
      node.set['authorization']['sudo']['users'] << u
      node.set['authorization']['sudo']['group'] << g
      include_recipe "users::sudo"
   end

   execute "passwd -l #{u['username']}"

   group "#{u['username']}" do
    members "#{u['username']}"
    append true
   end

  else
    Chef::Log.info "skystack::stackadmin no settings for a stackadmin"
  end
