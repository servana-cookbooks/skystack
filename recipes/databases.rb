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

   if db['phpmyadmin'] == true
    Chef::Log.info("Creating PHPMyAdmin profile for: #{db["name"]}")

    include_recipe "phpmyadmin"
    
    phpmyadmin_db "#{db["name"]}" do
        host '127.0.0.1'
        port 3306
        auth_type "cookie"
        username "#{db["user"]}"
        password "#{db["password"]}"
        hide_dbs %w{ information_schema mysql phpmyadmin performance_schema }
    end

   end

   
end