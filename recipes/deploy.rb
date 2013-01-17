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




if node['deploy']
app = node['deploy']

  if app['force']
   deploy_action = app['force']
  else
   deploy_action = :deploy
  end

  if app['symlinks']
    app_symlinks = {}

    app['symlinks'].each do |link|
      app_symlinks[link['from']] = link['to']
    end
  else  
      app_symlinks = {}
  end

  deploy_revision app['name'] do
    environment({"HOME" => app['home']})
    revision app['revision']
    repository app['repository']
    user app['owner']
    group app['group']
    deploy_to app['path']
    current_path "#{app['path']}/current"
    action deploy_action
    git_ssh_wrapper app['ssh_wrapper']
    shallow_clone true
    purge_before_symlink([])
    create_dirs_before_symlink([])
    symlinks(app_symlinks)
    symlink_before_migrate({
    #  local_settings_file_name => local_settings_full_path
    })
  end

end
