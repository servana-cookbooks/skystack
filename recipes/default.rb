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

if node['scripts'] && node['scripts']['before_configure']
    node.set['scripts']['run_scripts'] = node['scripts']['before_configure']
  include_recipe "skystack::script"
end

if ! node['databases'].nil?
	include_recipe "skystack::databases"
end

if ! node['firewall'].nil?
	include_recipe "skystack::firewall"
end

if ! node['sites'].nil?
  include_recipe "skystack::sites"
end

if node['scripts'] && node['scripts']['after_configure']
    node.set['scripts']['run_scripts'] = node['scripts']['after_configure']
  include_recipe "skystack::script"
end

if node["users"] && node["groups"]
  include_recipe "users"
end
