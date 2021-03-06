# Cookbook Name:: skystack
# Recipe:: skystack::script
# Description:: Multi-purpose recipe for executing SkyScripts during the bootstrap/commission and decommission phases, the recipe uses a lock file to prevent further execution.
# Copyright:: 2010, Skystack, Ltd.
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

node['scripts']['run_scripts'].each do |script|
  
  execute "run-script-#{script["filename"]}" do
    command "#{node['scripts']['path']}/#{script["filename"]}; touch #{node['scripts']['path']}/executed-#{script["filename"]}"
    action :nothing
    only_if do ! File.exists?( "#{node['scripts']['path']}/executed-#{script["filename"]}" ) end
  end

  execute "get-script" do 
    command "curl -k -o #{node['scripts']['path']}/#{script["filename"]} -u #{node['userdata']['API_USER']}:#{node['userdata']['API_TOKEN']} #{script['url']}"
    notifies :run, resources(:execute => "run-script-#{script["filename"]}")
    creates "#{node['scripts']['path']}/#{script["filename"]}"
  end

end