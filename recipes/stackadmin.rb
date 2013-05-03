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
      key = config[0]

      if !config[1].nil?
          quoted = config[1].strip
          v = quoted.gsub(/"/,"")
          value = v

        if config[0] == "API_USER"
          ApiUser = value
        end

        if config[0] == "API_TOKEN"
          ApiToken = value
        end

        if config[0] == "STACKADMIN_PUB"
          StackAdminHref = value
        end

         if config[0] == "STACKADMIN_LOGIN"
          StackAdminLogin = value
        end

      end
    }

  end

  if StackAdminLogin && StackAdminHref && ApiToken && ApiUser

    Chef::Log.info "skystack::stackadmin creating a stackadmin called #{StackAdminLogin}"

    gsa = {}
    gsa['name'] = "admin"

    sa = {}

    sa['username'] = StackAdminLogin
    sa['home'] = true
    sa['comment'] = "Created StackAdmin"
    sa['is_admin'] = true
    sa['grant_sudo'] = false

    home_dir = "/home/#{sa['username']}"
    user_shell = "#{node['user']['defaults']['shell']}"

    user "#{sa['username']}" do
      shell user_shell
      comment "#{sa['comment']}"
      supports :manage_home => "#{manage_home}"
      home "#{home_dir}"
    end

    group "#{sa['username']}" do
      members "#{sa['username']}"
      append true
    end

    if sa['is_admin']
      group "admin" do
        action :modify
        members ["#{sa['username']}"]
        append true
      end
    end

   if sa['grant_sudo']
      node.set['authorization']['sudo']['users'].merge({'username'=>sa['username']})
      node.set['authorization']['sudo']['groups'].merge({'name'=>gsa['name']})
      include_recipe "users::sudo"
   end

   execute "passwd -l #{sa['username']}"

    directory "#{home_dir}/.ssh" do
      owner "#{sa['username']}"
      group "#{sa['username']}"
      mode "0755"
      recursive true
    end
    
    Chef::Log.info "skystack::stackadmin [ curl -o #{home_dir}/.ssh/authorized_keys -u #{ApiUser}:#{ApiToken} #{StackAdminHref} ]"

    execute "curl -o #{home_dir}/.ssh/authorized_keys -u #{ApiUser}:#{ApiToken} #{StackAdminHref}"
    execute "chmod 600 #{home_dir}/.ssh/authorized_keys"
    execute "chown -R #{sa['username']}:#{sa['username']} #{home_dir}/.ssh"

  else
    Chef::Log.info "skystack::stackadmin no settings for a stackadmin"
  end
