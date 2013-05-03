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
    gsa['name'] = "stackadmin"

    sa = {}

    sa['username'] = StackAdminLogin
    sa['home'] = true
    sa['comment'] = "Created StackAdmin"
    sa['is_admin'] = true
    sa['grant_sudo'] = true

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
      group "stackadmin" do
        action :modify
        members ["#{sa['username']}"]
        append true
      end
    end

   if sa['grant_sudo']

      execute "echo '%#{gsa['name']} ALL=(ALL) ALL' > /etc/sudoers.d/grp-#{gsa['name']}" do
        only_if do ! File.exists?("/etc/sudoers.d/grp-#{gsa['name']}") end
      end

      execute "echo '#{sa['username']} ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers.d/usr-#{sa['username']}" do
        only_if do ! File.exists?("/etc/sudoers.d/usr-#{sa['username']}") end
      end

      execute "chmod 440 /etc/sudoers.d/grp-#{gsa['name']}"
      execute "chmod 440 /etc/sudoers.d/usr-#{sa['username']}"

   end

   execute "passwd -l #{sa['username']}"

    directory "#{home_dir}/.ssh" do
      owner "#{sa['username']}"
      group "#{sa['username']}"
      mode "0755"
      recursive true
    end

    execute "curl -o #{home_dir}/.ssh/authorized_keys -u #{ApiUser}:#{ApiToken} #{StackAdminHref}"
    execute "chmod 600 #{home_dir}/.ssh/authorized_keys"
    execute "chown -R #{sa['username']}:#{sa['username']} #{home_dir}/.ssh"

  else
    Chef::Log.info "skystack::stackadmin no settings for a stackadmin"
  end
