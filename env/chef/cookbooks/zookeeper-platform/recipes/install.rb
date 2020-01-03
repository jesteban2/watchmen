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

# tar may not be installed by default
package_retries = node[cookbook_name]['package_retries']
package 'tar' do
  package_retries unless package_retries.nil?
end

# Shorten variables
version = node[cookbook_name]['version']
zookeeper_url = "#{node[cookbook_name]['mirror']}/zookeeper-#{version}"
zookeeper_artifact = "zookeeper-#{version}.tar.gz"

# Create prefix directories
[
  node[cookbook_name]['prefix_root'],
  node[cookbook_name]['prefix_home'],
  node[cookbook_name]['prefix_bin']
].uniq.each do |dir_path|
  directory "zookeeper-platform:#{dir_path}" do
    path dir_path
    owner 'root'
    group 'root'
    mode '0755'
    recursive true
    action :create
  end
end

# Install zookeeper package with ark
ark 'zookeeper' do
  action :install
  url "#{zookeeper_url}/#{zookeeper_artifact}"
  prefix_root node[cookbook_name]['prefix_root']
  prefix_home node[cookbook_name]['prefix_home']
  prefix_bin node[cookbook_name]['prefix_bin']
  has_binaries [] # zookeeper script does not work when linked
  checksum node[cookbook_name]['checksum']
  version node[cookbook_name]['version']
end

# Symbolic link for zookeeper jar to simplify service file
install_dir = "#{node[cookbook_name]['prefix_home']}/zookeeper"
link "#{install_dir}/zookeeper.jar" do
  to "#{install_dir}/zookeeper-#{version}.jar"
end
