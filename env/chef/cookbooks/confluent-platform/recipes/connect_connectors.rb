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

# Search Kafka Connect cluster
cluster = cluster_search(node[cookbook_name]['connect'])
return if cluster.nil? # Not enough nodes

id = node[cookbook_name]['connect']['initiator']
if id < 1 && id > cluster['size']
  raise "Invalid Kafka Connect initiator: #{id},"\
    " cluster size: #{cluster['size']}"
end

# Exit this recipe if I am not the one
return if cluster['my_id'] != id

# Post job with API
node[cookbook_name]['connect']['connectors'].to_h.each_pair do |name, rconf|
  resource = confluent_platform_connector name
  rconf.each_pair { |k, v| resource.send(k.to_sym, v) }
end
