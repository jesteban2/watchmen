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
node.run_state[cookbook_name]['registry'] ||= {}

# Will be set to false if searchs succeed, at the end of this recipe
node.run_state[cookbook_name]['registry']['interrupted'] = true

# Use ClusterSearch
::Chef::Recipe.send(:include, ClusterSearch)

# Get default configuration
config = node[cookbook_name]['registry']['config'].to_hash

# Search Kafka brokers
kafka_brokers = cluster_search(node[cookbook_name]['kafka'])
if kafka_brokers.nil? # Not enough node, let's try by zookeeper
  # Search Zookeeper cluster
  zookeeper = cluster_search(node[cookbook_name]['zookeeper'])
  return if zookeeper.nil? # Not enough nodes

  zk_connection = zookeeper['hosts'].map do |host|
    "#{host}:#{node[cookbook_name]['kafka']['zk_port']}"
  end.join(',') + node[cookbook_name]['kafka']['zk_chroot']
  config['kafkastore.connection.url'] = zk_connection
else # We found brokers, let's define bootstrap.servers
  protocol = node[cookbook_name]['kafka']['protocol']
  kafka_connection = kafka_brokers['hosts'].map do |host|
    "#{protocol}://#{host}:#{node[cookbook_name]['kafka']['port']}"
  end.join(',')
  config['kafkastore.bootstrap.servers'] = kafka_connection
end

# Write configurations
files = {
  '/etc/schema-registry/schema-registry.properties' => config,
  '/etc/schema-registry/log4j.properties' =>
    node[cookbook_name]['registry']['log4j']
}
node.run_state[cookbook_name]['registry']['conf_files'] = files.keys

files.each do |file, conf|
  run_state = node.run_state[cookbook_name]
  run_state['registry'][file] = conf

  template file do
    sensitive node[cookbook_name]['sensitive']
    source 'properties.erb'
    mode '644'
    variables config: lazy { run_state['registry'][file].sort.to_h }
  end
end

# Create Registry log dir
log_dir = node[cookbook_name]['registry']['log4j']['schema-registry.log.dir']
directory "#{recipe_name}:#{log_dir}" do
  path log_dir
  owner 'root'
  group node[cookbook_name]['registry']['group']
  mode '0775'
  recursive true
  action :create
  not_if { log_dir.nil? }
end

# Everything was fine
node.run_state[cookbook_name]['registry']['interrupted'] = false
