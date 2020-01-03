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

property :topic, String, name_property: true
property :zookeeper, String, default: 'localhost:2181'
property :partitions, Integer
property :replication, Integer
property :config, Hash, default: {}
# We may have to wait until changes are effective
# property :waits, Integer, default: 10
# property :waits_delay, Integer, default: 2

default_action :create

action :create do
  topic = new_resource.topic
  zookeeper = new_resource.zookeeper
  replication = new_resource.replication
  partitions = new_resource.partitions
  config = new_resource.config

  unless exist?(zookeeper, topic)
    converge_by "create #{topic} topic" do
      create_topic(zookeeper, topic, replication, partitions, config)
    end
  end
end

action :delete do
  topic = new_resource.topic
  zookeeper = new_resource.zookeeper

  if exist?(zookeeper, topic)
    converge_by "delete #{topic} topic (Note: need delete.topic.enable)" do
      delete_topic(zookeeper, topic)
    end
  end
end

def exist?(zkp, topic)
  cmd = "kafka-topics --zookeeper #{zkp} --list --topic #{topic}"
  shell_out!(cmd).stdout.chomp == topic
end

def create_topic(zkp, topic, replication, partitions, config)
  conf_str = config.map { |k, v| "--config #{k}=#{v}" }.join(' ')
  shell_out!(
    <<-BASH
      kafka-topics --zookeeper #{zkp} --create \
        --topic #{topic} \
        #{"--partitions #{partitions}" unless partitions.nil?} \
        #{"--replication-factor #{replication}" unless replication.nil?} \
        #{conf_str}
    BASH
  )
end

def delete_topic(zkp, topic)
  shell_out!("kafka-topics --zookeeper #{zkp} --delete --topic #{topic}")
end
