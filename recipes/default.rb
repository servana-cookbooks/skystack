# Cookbook Name:: skystack
# Recipe:: skystack::default
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

execute "echo #{node.to_json} > #{node['skystack']['log_path']}/node.json"

require 'ohai'
 o = Ohai::System.new
 o.all_plugins
 total_memory = o['memory']['total'].tr('kb','').to_i()
 free_memory = o['memory']['free'].tr('kb','').to_i()

 size = case total_memory
  when total_memory < 630000 then 0.5
  when total_memory < 1048576 then 1
  when total_memory < 2097152 then 2
  when total_memory < 4194304 then 4
  when total_memory < 8388608 then 8
  when total_memory < 16777216 then 16  
  when total_memory < 33554432 then 32
  when total_memory < 67108864 then 64 
end

node.set['skystack']['memory'] = size

Chef::Log.info "skystack::default total memory #{node['skystack']['memory']}"

if ! node['sites'].nil?
	include_recipe "skystack::sites"
end

if ! node['databases'].nil?
	include_recipe "skystack::databases"
end

if ! node['firewall'].nil?
	include_recipe "skystack::firewall"
end

if ! node['scripts'].nil?
	include_recipe "skystack::scripts"
end

node['run_list'].each do |run|

  case run
    when "role[wordpress_server]" then
      include_recipe "wordpress"
    when "role[drupal_server]" then
    when "role[symphony_server]" then
    when "role[cakephp_server]" then
    when "role[symfony_server]" then
    when "role[lithium_server]" then
    when "role[magento_server]" then  
  end

end
