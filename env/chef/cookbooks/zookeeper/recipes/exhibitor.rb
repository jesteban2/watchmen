#
# Cookbook Name:: zookeeper
# Recipe:: Exhibitor
#
# Copyright 2013, Simple Finance Technology Corp.
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

include_recipe "zookeeper::gradle"
chef_gem "zookeeper"
chef_gem "json"

group node[:exhibitor][:group] do
  action :create
end

user node[:exhibitor][:user] do
  gid node[:exhibitor][:group]
end

include_recipe "zookeeper::zookeeper"

[node[:exhibitor][:install_dir],
  node[:exhibitor][:snapshot_dir],
  node[:exhibitor][:transaction_dir],
  node[:exhibitor][:log_index_dir]
].uniq.each do |dir|
  directory dir do
    owner node[:exhibitor][:user]
    mode "0755"
  end
end

jar_file = "#{Chef::Config[:file_cache_path]}/exhibitor/build/libs/exhibitor-#{node[:exhibitor][:version]}.jar"
if !::File.exists?(jar_file)
  execute "build exhibitor" do
    cwd ::File.join(Chef::Config[:file_cache_path], 'exhibitor')
    command 'gradle jar'
  end
end

exhibitor_jar = ::File.join(node[:exhibitor][:install_dir], "#{node[:exhibitor][:version]}.jar")
if !::File.exists?(exhibitor_jar)
  execute "move exhibitor jar" do
    user node[:exhibitor][:user]
    command "cp #{jar_file} #{exhibitor_jar}"
  end
end

check_script = ::File.join(node[:exhibitor][:script_dir], 'check-local-zk.py')
template check_script do
  owner node[:exhibitor][:user]
  mode "0744"
  variables(
    :exhibitor_port => node[:exhibitor][:opts][:port],
    :localhost => node[:exhibitor][:opts][:hostname] )
end

template "/etc/init/exhibitor.conf" do
  source "exhibitor.upstart.conf.erb"
  owner "root"
  group "root"
  mode "0644"
  notifies :stop, "service[exhibitor]" # :restart doesn't reload upstart conf
  notifies :start, "service[exhibitor]"
  variables(
    :user => node[:exhibitor][:user],
    :jar => "#{node[:exhibitor][:install_dir]}/#{node[:exhibitor][:version]}.jar",
    :opts => node[:exhibitor][:opts],
    :check_script => check_script )
end

template node[:exhibitor][:opts][:defaultconfig] do
  owner node[:exhibitor][:user]
  mode "0644"
  variables(
    :snapshot_dir => node[:exhibitor][:snapshot_dir],
    :transaction_dir => node[:exhibitor][:transaction_dir],
    :log_index_dir => node[:exhibitor][:log_index_dir],
    :defaultconfig => node[:exhibitor][:defaultconfig] )
end

service "exhibitor" do
  provider Chef::Provider::Service::Upstart
  supports :start => true, :status => true, :restart => true
  action :start
end

