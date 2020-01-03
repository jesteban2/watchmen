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

::Chef::Recipe.send(:include, ClusterSearch)
cluster = cluster_search(node[cookbook_name])
node.run_state[cookbook_name] ||= {}
if cluster.nil?
  node.run_state[cookbook_name]['abort?'] = true
  return
end

# Generate config
config = node[cookbook_name]['config'].dup
cluster['hosts'].each_with_index do |v, i|
  config["server.#{i + 1}"] = "#{v}:2888:3888"
end

# Create work directories
[
  node[cookbook_name]['log_dir'],
  node[cookbook_name]['data_dir']
].each do |path|
  directory path do
    owner node[cookbook_name]['user']
    group node[cookbook_name]['user']
    mode '0755'
    recursive true
    action :create
  end
end

# General zookeeper config
config_path = "#{node[cookbook_name]['prefix_home']}/zookeeper/conf"

template "#{config_path}/zoo.cfg" do
  variables config: config
  mode '0644'
  source 'zoo.cfg.erb'
end

# Log4j
template "#{config_path}/log4j.properties" do
  source 'properties.erb'
  mode '644'
  variables config: node[cookbook_name]['log4j']
end

# Create myid file
template "#{node[cookbook_name]['data_dir']}/myid" do
  variables my_id: cluster['my_id']
  mode '0644'
  source 'myid.erb'
end
