# frozen_string_literal: true

#
# Copyright (c) 2018 Make.org
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
node.run_state[cookbook_name]['connect'] ||= {}

# Will be set to false if searchs succeed, at the end of this recipe
node.run_state[cookbook_name]['connect']['interrupted'] = true
run_state = node.run_state[cookbook_name]

# Use ClusterSearch
::Chef::Recipe.send(:include, ClusterSearch)

# Get default configuration
config = node[cookbook_name]['connect']['config'].to_hash

# Search Kafka brokers
kafka_brokers = cluster_search(node[cookbook_name]['kafka'])
return if kafka_brokers.nil? # Not enough node

protocol = node[cookbook_name]['kafka']['protocol']
kafka_connection = kafka_brokers['hosts'].map do |host|
  "#{protocol}://#{host}:#{node[cookbook_name]['kafka']['port']}"
end.join(',')

config['bootstrap.servers'] = kafka_connection

# Write configurations
files = {
  '/etc/kafka/connect-distributed.properties' => config,
  '/etc/kafka/connect-log4j.properties' =>
    node[cookbook_name]['connect']['log4j']
}

node.run_state[cookbook_name]['connect']['conf_files'] = files.keys

files.each do |file, conf|
  run_state = node.run_state[cookbook_name]
  run_state['connect'][file] = conf

  template file do
    sensitive node[cookbook_name]['sensitive']
    source 'properties.erb'
    mode '644'
    variables config: lazy { run_state['connect'][file].sort.to_h }
  end
end

# Everything was fine
node.run_state[cookbook_name]['connect']['interrupted'] = false
