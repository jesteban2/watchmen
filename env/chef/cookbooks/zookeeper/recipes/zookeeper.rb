#
# Cookbook Name:: zookeeper
# Recipe:: zookeeper
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

include_recipe "java::default"

zk_basename = "zookeeper-#{node[:zookeeper][:version]}"

remote_file ::File.join(Chef::Config[:file_cache_path], "#{zk_basename}.tar.gz") do
  owner "root"
  mode "0644"
  source node[:zookeeper][:mirror]
  checksum node[:zookeeper][:checksum]
  action :create
end

directory node[:zookeeper][:install_dir] do
  owner node[:exhibitor][:user]
  mode "0755"
end

if !Dir.exists?(::File.join(Chef::Config[:file_cache_path], zk_basename))
  execute 'install zookeeper' do
    user node[:exhibitor][:user]
    cwd Chef::Config[:file_cache_path]
    command <<-eos 
      tar -C #{node[:zookeeper][:install_dir]} -zxf #{zk_basename}.tar.gz
    eos
  end
end

