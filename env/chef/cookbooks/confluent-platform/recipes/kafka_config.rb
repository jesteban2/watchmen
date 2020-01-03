# frozen_string_literal: true

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

# To be used in service
node.run_state[cookbook_name] ||= {}
node.run_state[cookbook_name]['kafka'] ||= {}

# Will be set to false if searchs succeed, at the end of this recipe
node.run_state[cookbook_name]['kafka']['interrupted'] = true

# Use ClusterSearch
::Chef::Recipe.send(:include, ClusterSearch)

# Get default configuration
config = node[cookbook_name]['kafka']['config'].to_hash

# Search Zookeeper cluster
zookeeper = cluster_search(node[cookbook_name]['zookeeper'])
return if zookeeper.nil? # Not enough nodes

zk_connection = zookeeper['hosts'].map do |host|
  "#{host}:#{node[cookbook_name]['kafka']['zk_port']}"
end.join(',') + node[cookbook_name]['kafka']['zk_chroot']
config['zookeeper.connect'] = zk_connection

# Write configurations
files = {
  '/etc/kafka/server.properties' => config,
  '/etc/kafka/log4j.properties' => node[cookbook_name]['kafka']['log4j']
}
node.run_state[cookbook_name]['kafka']['conf_files'] = files.keys

files.each do |file, conf|
  run_state = node.run_state[cookbook_name]
  run_state['kafka'][file] = conf

  template file do
    sensitive node[cookbook_name]['sensitive']
    source 'properties.erb'
    mode '644'
    variables config: lazy { run_state['kafka'][file].sort.to_h }
  end
end

# Create Kafka work directories with correct ownership
directory node[cookbook_name]['kafka']['config']['log.dirs'] do
  owner node[cookbook_name]['kafka']['user']
  group node[cookbook_name]['kafka']['group']
  mode '0755'
  recursive true
  action :create
end

# Create Kafka log4j dir
log4j_dir = node[cookbook_name]['kafka']['log4j']['kafka.logs.dir']
directory "#{recipe_name}:#{log4j_dir}" do
  path log4j_dir
  owner 'root'
  group node[cookbook_name]['kafka']['group']
  mode '0775'
  recursive true
  action :create
  not_if { log4j_dir.nil? }
end

# Everything was fine
node.run_state[cookbook_name]['kafka']['interrupted'] = false
