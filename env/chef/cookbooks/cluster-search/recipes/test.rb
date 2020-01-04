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

# Recipe to test our library
::Chef::Recipe.send(:include, ClusterSearch)

test_list = []
i = 0

node[cookbook_name]['test-cases'].each do |test, expected|
  test_list << "#{test}##{expected}"
  i += 1
  begin
    if test['fun'].nil?
      cluster = cluster_search(test)
    else
      fun = eval(test['fun']) # rubocop:disable Security/Eval
      cluster = cluster_search(test, &fun)
    end
  rescue StandardError => error
    cluster = error
  end

  file "/tmp/testcase_#{format('%02d', i)}" do
    content cluster.to_s
  end
end

file '/tmp/test_list' do
  content test_list.join("\n") + "\n"
end
