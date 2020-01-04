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

# Kafka Connect is included in Kafka package
include_recipe "#{cookbook_name}::kafka_package"

package_retries = node[cookbook_name]['package_retries']
pkg_version = node[cookbook_name]['hub']['version']

# Install Confluent Hub package
package node[cookbook_name]['hub']['package'] do
  retries package_retries unless package_retries.nil?
  version pkg_version unless pkg_version.nil? || pkg_version == 'latest'
  action :upgrade if pkg_version == 'latest'
end

node.run_state[cookbook_name] ||= {}
node.run_state[cookbook_name]['connect'] ||= {}
node.run_state[cookbook_name]['connect']['restart_resources'] ||= []

# Install Components from Confluent Hub
node[cookbook_name]['connect']['components'].each_pair do |ownername, version|
  pkg = "#{ownername}:#{version}"
  dir = '/usr/share/confluent-hub-components'
  directory dir do
    recursive true
  end

  execute "Install #{pkg}" do
    command "confluent-hub install --component-dir #{dir} --no-prompt #{pkg}"
    live_stream true
    not_if do
      begin
        file = File.read("#{dir}/#{ownername.tr('/', '-')}/manifest.json")
        current_version = JSON.parse(file)['version']
        ['latest', current_version].include?(version)
      rescue Errno::ENOENT
        false
      end
    end
  end

  node.run_state[cookbook_name]['connect']['restart_resources'].append(
    "execute[Install #{pkg}]"
  )
end
