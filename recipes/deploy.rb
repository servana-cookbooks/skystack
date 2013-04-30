# Cookbook Name:: skystack
# Recipe:: skystack::deploy
# Copyright:: 2012, Skystack Limited.
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


# "deployments":[
#      "config":
#      {
#          "strategy":"archive",
#      },
#    "name":"WKDAPP",
#    "fetch_archive_command":"curl -L -o /opt/skystack/downloads/github_arch.zip -H 'https://api.github.com/repos/user/repo/zipball'",
#    "archive_path":"/opt/skystack/downloads/github_arch.zip",
#    "base_path":"/var/www/vhosts/WKDAPP.com",
#    "deploy_path":"/var/www/vhosts/WKDAPP.com/releases",
#    "shared_path":"/var/www/vhosts/WKDAPP.com/shared",
#    "symlink":"/var/www/vhosts/WKDAPP.com/current"
# ],

if node['deployments']

  node['deployments'].each do |deploy|
    if deploy['config']['type'] == 'archive'
     include_recipe "skystack::deploy_archive"
    elsif deploy['config']['type'] == 'repo'
     include_recipe "skystack::deploy_repo"
    end
  end

end
