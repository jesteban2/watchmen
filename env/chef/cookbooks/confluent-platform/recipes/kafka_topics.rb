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

# Use ClusterSearch
::Chef::Recipe.send(:include, ClusterSearch)

# Search Kafka cluster to know my id
cluster = cluster_search(node[cookbook_name]['kafka'])
return if cluster.nil? # Not enough nodes

id = node[cookbook_name]['kafka']['id_topic_creator']
if id < 1 && id > cluster['size']
  raise "Invalid Kafka ID: #{id},"\
    " cluster size: #{cluster['size']}"
end

# Exit this recipe if I am not the one
return if cluster['my_id'] != id

# Search Zookeeper cluster
zookeeper = cluster_search(node[cookbook_name]['zookeeper'])
return if zookeeper.nil? # Not enough nodes

zk_connection = zookeeper['hosts'].map do |host|
  "#{host}:#{node[cookbook_name]['kafka']['zk_port']}"
end.join(',') + node[cookbook_name]['kafka']['zk_chroot']

kafka_config = node[cookbook_name]['kafka']['config']
node[cookbook_name]['kafka']['topics'].each_pair do |topic, r_config|
  resource = confluent_platform_topic topic do
    zookeeper(zk_connection)
    partitions kafka_config['num.partitions']
    replication kafka_config['default.replication.factor']
  end
  r_config.each_pair { |k, v| resource.send(k.to_sym, v) }
end
