# Cookbook Name:: skystack
# Recipe:: skystack::databases
#
# Copyright 2010, Skystack, Ltd.
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


gem_package "mysql2" do
  action :install
  ignore_failure true
end

node["databases"].each do |db|
  
   skystack_database "create_#{db["name"]}" do
      provider "skystack_mysql"
      root_username "root"
      root_password node['mysql']['server_root_password']
      database db["name"]
      username db["user"]
      password db["password"]
      host "localhost"
      priv "#{db["permissions"].join(",")}"
      action [:create, :grant, :flush]
   end

end

if !node['mysql']['daily_backup'].nil?

    cookbook_file "/usr/local/bin/automysqlbackup" do
      source "automysqlbackup"
      backup false
      path "/usr/local/bin"
      action :create_if_missing
    end

    execute "chmod +x /usr/local/bin/automysqlbackup" do
      only_if do File.exists?('/usr/local/bin/automysqlbackup') end
    end

    directory '/etc/automysqlbackup' do
      mode 00755
      action :create
      owner 'root'
      group 'root'
      recursive true
    end

    template "/etc/automysqlbackup/automysqlbackup.conf" do
      source "automysqlbackup.conf.erb"
      owner "root"
      group "root"
      mode "0644"
      variables(
        :host               => 'localhost',
        :user               => 'root',
        :password           => node['mysql']['server_root_password'],
        :backup_email       => node['mysql']['backup_email']
      )
    end

    cookbook_file "/etc/cron.daily/automysqlbackup.cron.sh" do
      source "automysqlbackup.cron.sh"
      backup false
      path "/etc/cron.daily"
      action :create_if_missing
    end
    
    execute "chmod +x /usr/local/bin/automysqlbackup.cron.sh" do
      only_if do File.exists?('/usr/local/bin/automysqlbackup.cron.sh') end
    end

end
