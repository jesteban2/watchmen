#
# Copyright (c) 2015-2016 Sam4Mobile, 2017-2018 Make.org
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

# We do not want to continue if the config is incorrect
node.run_state[cookbook_name] ||= {}
return if node.run_state[cookbook_name]['abort?']

# Install and launch zookeeper service through systemd
config_path = "#{node[cookbook_name]['prefix_home']}/zookeeper/conf"
install_path = "#{node[cookbook_name]['prefix_home']}/zookeeper"

service_config = {
  classpath: "#{install_path}/zookeeper.jar:#{install_path}/lib/*",
  config_file: "#{config_path}/zoo.cfg",
  log4j_file: "#{config_path}/log4j.properties"
}

# Install service file, reload systemd daemon if necessary
execute 'zookeeper-platform:systemd-reload' do
  command 'systemctl daemon-reload'
  action :nothing
end

unit_file = "#{node[cookbook_name]['unit_path']}/zookeeper.service"
template unit_file do
  variables service_config
  mode '0644'
  source 'zookeeper.service.erb'
  notifies :run, 'execute[zookeeper-platform:systemd-reload]', :immediately
end

# Java is needed by Kafka, can install it with package
java = node[cookbook_name]['java']
# java installation can be intentionally ignored by setting the whole key to ''
unless java.to_s.empty?
  java_package = java[node['platform']]

  if java_package.to_s.empty?
    Chef::Log.warn  "No java specified for the platform #{node['platform']}, "\
                    'java will not be installed'

    Chef::Log.warn  'Please specify a java package name if you want to '\
                    'install java using this cookbook.'
  else
    package_retries = node[cookbook_name]['package_retries']
    package java_package do
      retries package_retries unless package_retries.nil?
    end
  end
end

# Configuration files to be subscribed
config_files = [
  "#{config_path}/zoo.cfg",
  "#{config_path}/log4j.properties",
  "#{node[cookbook_name]['data_dir']}/myid"
].map do |path|
  "template[#{path}]"
end

auto_restart = node[cookbook_name]['auto_restart']
# Enable/Start service
service 'zookeeper' do
  provider Chef::Provider::Service::Systemd
  supports status: true, restart: true, reload: true
  action %i[enable start]
  subscribes :restart, config_files if auto_restart
end
