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

# Install Kafka with configured scala version
scala_version = node[cookbook_name]['scala_version']
package_retries = node[cookbook_name]['package_retries']
pkg_version = node[cookbook_name]['kafka']['version']

package "confluent-kafka-#{scala_version}" do
  retries package_retries unless package_retries.nil?
  version pkg_version unless pkg_version.nil? || pkg_version == 'latest'
  action :upgrade if pkg_version == 'latest'
end
