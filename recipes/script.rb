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

script = node.run_state[:current_app]


node["scripts"].each do |script|
  
  Chef::Log.info "skystack::script telling chef to run this script #{script["resource"]}"
  
  execute "run-script-#{script["resource"]}" do
    command "/tmp/#{script["resource"]}; touch /opt/skystack/tmp/executed-#{script["resource"]}"
    action :nothing
    only_if do ! File.exists?( "/opt/skystack/tmp/executed-#{script["resource"]}" ) end
  end

  #all interactions with our API should be done via a Ruby script to cleanup the execution of a SkyScript.
  Chef::Log.info "skystack::script via skystack we fetch the script contents #{script["resource"]}"

  bash "get-script" do
    user "root"
    cwd "/tmp"
    code <<-EOH
    export SKYSTACK_PATH=/opt/skystack
    export ALIAS=`awk '/ALIAS/ {print $2}' FS=\= $SKYSTACK_PATH/etc/userdata.conf` > /dev/null 2>&1
    export API_TOKEN=`awk '/API_TOKEN/ {print $2}' FS=\= $SKYSTACK_PATH/etc/userdata.conf` > /dev/null 2>&1
    export API_USER=`awk '/API_USER/ {print $2}' FS=\= $SKYSTACK_PATH/etc/userdata.conf` > /dev/null 2>&1
    export BASE=`awk '/BASE/ {print $2}' FS=\= $SKYSTACK_PATH/etc/userdata.conf` > /dev/null 2>&1

    HTTP=https

    curl -k -o /tmp/#{script["resource"]}-raw -u $API_USER:$API_TOKEN $HTTP://$BASE/$ALIAS/scripts/#{script["identifier"]}/out.bash

    tr -d '\015\032' < /tmp/#{script["resource"]}-raw > /tmp/#{script["resource"]}

    chmod +x /tmp/#{script["resource"]}

    EOH
    notifies :run, resources(:execute => "run-script-#{script["resource"]}")
    creates "/tmp/#{script["resource"]}"
  end
end