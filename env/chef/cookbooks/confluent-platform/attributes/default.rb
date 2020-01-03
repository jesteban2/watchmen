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

# cookbook_name alias to be similar with recipes
cookbook_name = 'confluent-platform'

# Confluent version and general cookbook attributes
default[cookbook_name]['version'] = '5.0'
default[cookbook_name]['scala_version'] = '2.11'
default[cookbook_name]['java']['centos'] = 'java-1.8.0-openjdk-headless'
default[cookbook_name]['sensitive'] = false

# Systemd unit file path
default[cookbook_name]['unit_path'] = '/etc/systemd/system'

# Cluster search configuration
# To understand the following attributes, look at 'cluster-search' README

# Zookeeper cluster
default[cookbook_name]['zookeeper']['role'] = 'zookeeper-cluster'
default[cookbook_name]['zookeeper']['hosts'] = []
default[cookbook_name]['zookeeper']['size'] = 0

# Kafka cluster
default[cookbook_name]['kafka']['role'] = 'kafka-cluster'
default[cookbook_name]['kafka']['hosts'] = []
default[cookbook_name]['kafka']['size'] = 0
# Package version (major is defined by the repository)
# latest means it will be auto-upgraded
default[cookbook_name]['kafka']['version'] = 'latest'

# Schema Registry cluster
default[cookbook_name]['registry']['role'] = 'schema-registry-cluster'
default[cookbook_name]['registry']['hosts'] = []
default[cookbook_name]['registry']['size'] = 1
# Package version (major is defined by the repository)
# latest means it will be auto-upgraded
default[cookbook_name]['registry']['version'] = 'latest'

# Kafka Rest cluster
default[cookbook_name]['rest']['role'] = 'kafka-rest-cluster'
default[cookbook_name]['rest']['hosts'] = []
default[cookbook_name]['rest']['size'] = 1
# Package version (major is defined by the repository)
# latest means it will be auto-upgraded
default[cookbook_name]['rest']['version'] = 'latest'

# Kafka Connect cluster
# Use only by connect_connectors to avoid race condition while managing
# connectors. Only one node is truly needed, the "initiator".
default[cookbook_name]['connect']['role'] = 'kafka-connect-cluster'
default[cookbook_name]['connect']['hosts'] = []
default[cookbook_name]['connect']['size'] = 1
# id of initiator, position in search result, starting from 1
default[cookbook_name]['connect']['initiator'] = 1

# Confluent Hub, installed by 'connect' recipes
# Package version (major is defined by the repository)
# latest means it will be auto-upgraded
default[cookbook_name]['hub']['package'] = 'confluent-hub-client'
default[cookbook_name]['hub']['version'] = 'latest'

# Kafka configuration
# Port to connect on zookeeper (unsecure default is 2181, tls is 2281)
default[cookbook_name]['kafka']['zk_port'] = 2181
zk_port = node[cookbook_name]['kafka']['zk_port']

# Always use a chroot in Zookeeper
default[cookbook_name]['kafka']['zk_chroot'] =
  "/#{node[cookbook_name]['kafka']['role']}"

default[cookbook_name]['kafka']['user'] = 'cp-kafka'
default[cookbook_name]['kafka']['group'] = 'confluent'
# Restart service at configuration changes
default[cookbook_name]['kafka']['auto_restart'] = false

# Who will create topics
default[cookbook_name]['kafka']['id_topic_creator'] = 1

# Topics to create
default[cookbook_name]['kafka']['topics'] = {
  # topic_name => {
  #   'partitions' => 3
  #   'replication' => 3
  #   'config' => {
  #     'cleanup.policy' => 'compact'
  #   }
  # }
}

# Protocol and port, used to generate a default "listeners"
# and by other components to connect to brokers through a search
default[cookbook_name]['kafka']['protocol'] = 'PLAINTEXT'
default[cookbook_name]['kafka']['port'] = 9092

# Kafka configuration, default provided by Kafka project
default[cookbook_name]['kafka']['config'] = {
  'broker.id' => -1,
  'num.network.threads' => 3,
  'num.io.threads' => 8,
  'socket.send.buffer.bytes' => 102_400,
  'socket.receive.buffer.bytes' => 102_400,
  'socket.request.max.bytes' => 104_857_600,
  'log.dirs' => '/var/lib/kafka',
  'num.partitions' => 1,
  'default.replication.factor' => 1,
  'num.recovery.threads.per.data.dir' => 1,
  'offsets.topic.replication.factor' => 1,
  'transaction.state.log.replication.factor' => 1,
  'transaction.state.log.min.isr' => 1,
  'log.retention.hours' => 168,
  'log.segment.bytes' => 1_073_741_824,
  'log.retention.check.interval.ms' => 300_000,
  'log.cleaner.enable' => false,
  'zookeeper.connect' => "localhost:#{zk_port}", # will be replaced by a search
  'zookeeper.connection.timeout.ms' => 6_000,
  'confluent.support.metrics.enable' => false,
  'confluent.support.customer.id' => 'anonymous',
  'group.initial.rebalance.delay.ms' => 0
}

# CLI options which will be defined in Systemd unit
# Those options will be transformed:
# - all key value pair are merged to create a single command line
# - if value is 'nil' (string nil), the key is ignored (erase the option)
# - if value is empty, the value is ignored but the key is outputted
# - if key and value are defined, key=value is generated
# The reason for string 'nil' is because using true nil will not override
# a previously defined non-nil value.
default[cookbook_name]['kafka']['cli_opts'] = {
  '-Xms4g' => '',
  '-Xmx4g' => '',
  '-XX:+UseG1GC' => '',
  '-XX:MaxGCPauseMillis' => 20,
  '-XX:InitiatingHeapOccupancyPercent' => 35,
  '-Dcom.sun.management.jmxremote' => '',
  '-Dcom.sun.management.jmxremote.authenticate' => false,
  '-Dcom.sun.management.jmxremote.ssl' => false,
  '-Dcom.sun.management.jmxremote.port' => 8090,
  '-Djava.rmi.server.hostname' => node['fqdn']
}

# Kafka Systemd service unit, can include all JVM options in ExecStart
# by using cli_opts
# You can override java path and kafka options by overriding ExecStart values
default[cookbook_name]['kafka']['unit'] = {
  'Unit' => {
    'Description' => 'Kafka publish-subscribe messaging system',
    'After' => 'network.target'
  },
  'Service' => {
    'User' => node[cookbook_name]['kafka']['user'],
    'Group' => node[cookbook_name]['kafka']['group'],
    'SyslogIdentifier' => 'kafka',
    'Restart' => 'on-failure',
    'ExecStart' => {
      'start' => '/usr/bin/java',
      'end' =>
        '-Dlog4j.configuration=file:/etc/kafka/log4j.properties '\
        '-cp /usr/share/java/kafka/* '\
        'kafka.Kafka /etc/kafka/server.properties'
    }
  },
  'Install' => {
    'WantedBy' => 'multi-user.target'
  }
}

# Kafka log4j configuration
default[cookbook_name]['kafka']['log4j'] = {
  'kafka.logs.dir' => '/var/log/confluent',
  'log4j.rootLogger' => 'INFO, stdout, kafkaAppender',
  'log4j.appender.stdout' => 'org.apache.log4j.ConsoleAppender',
  'log4j.appender.stdout.layout' => 'org.apache.log4j.PatternLayout',
  'log4j.appender.stdout.layout.ConversionPattern' => '[%d] %p %m (%c)%n',
  'log4j.appender.kafkaAppender' =>
    'org.apache.log4j.DailyRollingFileAppender',
  'log4j.appender.kafkaAppender.DatePattern' => "'.'yyyy-MM-dd-HH",
  'log4j.appender.kafkaAppender.File' => '${kafka.logs.dir}/server.log',
  'log4j.appender.kafkaAppender.layout' => 'org.apache.log4j.PatternLayout',
  'log4j.appender.kafkaAppender.layout.ConversionPattern' =>
    '[%d] %p %m (%c)%n',
  'log4j.appender.stateChangeAppender' =>
    'org.apache.log4j.DailyRollingFileAppender',
  'log4j.appender.stateChangeAppender.DatePattern' =>
    "'.'yyyy-MM-dd-HH",
  'log4j.appender.stateChangeAppender.File' =>
    '${kafka.logs.dir}/state-change.log',
  'log4j.appender.stateChangeAppender.layout' =>
    'org.apache.log4j.PatternLayout',
  'log4j.appender.stateChangeAppender.layout.ConversionPattern' =>
    '[%d] %p %m (%c)%n',
  'log4j.appender.requestAppender' =>
    'org.apache.log4j.DailyRollingFileAppender',
  'log4j.appender.requestAppender.DatePattern' => "'.'yyyy-MM-dd-HH",
  'log4j.appender.requestAppender.File' =>
    '${kafka.logs.dir}/kafka-request.log',
  'log4j.appender.requestAppender.layout' => 'org.apache.log4j.PatternLayout',
  'log4j.appender.requestAppender.layout.ConversionPattern' =>
    '[%d] %p %m (%c)%n',
  'log4j.appender.cleanerAppender' =>
    'org.apache.log4j.DailyRollingFileAppender',
  'log4j.appender.cleanerAppender.DatePattern' => "'.'yyyy-MM-dd-HH",
  'log4j.appender.cleanerAppender.File' => '${kafka.logs.dir}/log-cleaner.log',
  'log4j.appender.cleanerAppender.layout' => 'org.apache.log4j.PatternLayout',
  'log4j.appender.cleanerAppender.layout.ConversionPattern' =>
    '[%d] %p %m (%c)%n',
  'log4j.appender.controllerAppender' =>
    'org.apache.log4j.DailyRollingFileAppender',
  'log4j.appender.controllerAppender.DatePattern' => "'.'yyyy-MM-dd-HH",
  'log4j.appender.controllerAppender.File' =>
    '${kafka.logs.dir}/controller.log',
  'log4j.appender.controllerAppender.layout' =>
    'org.apache.log4j.PatternLayout',
  'log4j.appender.controllerAppender.layout.ConversionPattern' =>
    '[%d] %p %m (%c)%n',
  'log4j.appender.authorizerAppender' =>
    'org.apache.log4j.DailyRollingFileAppender',
  'log4j.appender.authorizerAppender.DatePattern' => "'.'yyyy-MM-dd-HH",
  'log4j.appender.authorizerAppender.File' =>
    '${kafka.logs.dir}/kafka-authorizer.log',
  'log4j.appender.authorizerAppender.layout' =>
    'org.apache.log4j.PatternLayout',
  'log4j.appender.authorizerAppender.layout.ConversionPattern' =>
    '[%d] %p %m (%c)%n',
  'log4j.logger.org.I0Itec.zkclient.ZkClient' => 'INFO',
  'log4j.logger.org.apache.zookeeper' => 'INFO',
  'log4j.logger.kafka' => 'INFO',
  'log4j.logger.org.apache.kafka' => 'INFO',
  'log4j.logger.kafka.request.logger' => 'WARN, requestAppender',
  'log4j.additivity.kafka.request.logger' => 'false',
  'log4j.logger.kafka.network.RequestChannel$' => 'WARN, requestAppender',
  'log4j.additivity.kafka.network.RequestChannel$' => 'false',
  'log4j.logger.kafka.controller' => 'TRACE, controllerAppender',
  'log4j.additivity.kafka.controller' => 'false',
  'log4j.logger.kafka.log.LogCleaner' => 'INFO, cleanerAppender',
  'log4j.additivity.kafka.log.LogCleaner' => 'false',
  'log4j.logger.state.change.logger' => 'TRACE, stateChangeAppender',
  'log4j.additivity.state.change.logger' => 'false',
  'log4j.logger.kafka.authorizer.logger' => 'INFO, authorizerAppender',
  'log4j.additivity.kafka.authorizer.logger' => 'false'
}

# Schema Registry configuration
default[cookbook_name]['registry']['user'] = 'cp-schema-registry'
default[cookbook_name]['registry']['group'] = 'confluent'
# Restart service at configuration changes
default[cookbook_name]['registry']['auto_restart'] = false
# Will be used by rest after a search
default[cookbook_name]['registry']['port'] = 8081
default[cookbook_name]['registry']['config'] = {
  'listeners' => "http://0.0.0.0:#{node[cookbook_name]['registry']['port']}",
  # 'kafkastore.bootstrap.servers' will be filled by a search on
  # node[cookbook_name]['kafka'] using '[kafka][protocol]' and '[kafka][port]'.
  # If not enough nodes are found, then 'kafkastore.connection.url' will be
  # filled by a search on node[cookbook_name]['zookeeper']
  'kafkastore.topic' => '_schemas',
  'debug' => 'false'
}

default[cookbook_name]['registry']['log4j'] = {
  'schema-registry.log.dir' => '/var/log/confluent',
  'log4j.rootLogger' => 'INFO, stdout, file',
  'log4j.appender.stdout' => 'org.apache.log4j.ConsoleAppender',
  'log4j.appender.stdout.layout' => 'org.apache.log4j.PatternLayout',
  'log4j.appender.stdout.layout.ConversionPattern' => '[%d] %p %m (%c:%L)%n',
  'log4j.logger.kafka' => 'ERROR, stdout',
  'log4j.logger.org.apache.zookeeper' => 'ERROR, stdout',
  'log4j.logger.org.apache.kafka' => 'ERROR, stdout',
  'log4j.logger.org.I0Itec.zkclient' => 'ERROR, stdout',
  'log4j.additivity.kafka.server' => 'false',
  'log4j.additivity.kafka.consumer.ZookeeperConsumerConnector' => 'false',
  'log4j.appender.file' => 'org.apache.log4j.RollingFileAppender',
  'log4j.appender.file.maxBackupIndex' => 10,
  'log4j.appender.file.maxFileSize' => '100MB',
  'log4j.appender.file.File' =>
    '${schema-registry.log.dir}/schema-registry.log',
  'log4j.appender.file.layout' => 'org.apache.log4j.PatternLayout',
  'log4j.appender.file.layout.ConversionPattern' => '[%d] %p %m (%c)%n'
}

# Schema Registry CLI configuration (see kafka cli_opts for documentation)
default[cookbook_name]['registry']['cli_opts'] = {
  '-Xms1g' => '',
  '-Xmx1g' => '',
  '-XX:+UseG1GC' => '',
  '-XX:MaxGCPauseMillis' => 20,
  '-XX:InitiatingHeapOccupancyPercent' => 35,
  '-Dcom.sun.management.jmxremote' => '',
  '-Dcom.sun.management.jmxremote.authenticate' => false,
  '-Dcom.sun.management.jmxremote.ssl' => false,
  '-Dcom.sun.management.jmxremote.port' => 8091,
  '-Djava.rmi.server.hostname' => node['fqdn']
}

# Kafka Systemd service unit, can include all JVM options in ExecStart
cp = %w[confluent-common rest-utils schema-registry].map do |path|
  "/usr/share/java/#{path}/*"
end.join(':')

default[cookbook_name]['registry']['unit'] = {
  'Unit' => {
    'Description' =>
      'Schema Registry provides a serving layer for your metadata',
    'After' => 'network.target'
  },
  'Service' => {
    'User' => node[cookbook_name]['registry']['user'],
    'Group' => node[cookbook_name]['registry']['group'],
    'SyslogIdentifier' => 'schema-registry',
    'Restart' => 'on-failure',
    'ExecStart' => {
      'start' => '/usr/bin/java',
      'end' =>
        '-Dlog4j.configuration=file:/etc/schema-registry/log4j.properties ' \
        "-cp #{cp} " \
        'io.confluent.kafka.schemaregistry.rest.Main ' \
        '/etc/schema-registry/schema-registry.properties'
    }
  },
  'Install' => {
    'WantedBy' => 'multi-user.target'
  }
}

# Kafka Rest configuration
default[cookbook_name]['rest']['user'] = 'cp-kafka-rest'
default[cookbook_name]['rest']['group'] = 'confluent'
# Restart service at configuration changes
default[cookbook_name]['rest']['auto_restart'] = false
default[cookbook_name]['rest']['config'] = {
  'listeners' => 'http://0.0.0.0:8082'
  # 'bootstrap.servers' will be filled by a search on [cookbook_name]['kafka']
  # using '[kafka][protocol]' and '[kafka][port]'
}
default[cookbook_name]['rest']['log4j'] = {
  'kafka-rest.log.dir' => '/var/log/confluent',
  'log4j.rootLogger' => 'INFO, stdout, file',
  'log4j.appender.stdout' => 'org.apache.log4j.ConsoleAppender',
  'log4j.appender.stdout.layout' => 'org.apache.log4j.PatternLayout',
  'log4j.appender.stdout.layout.ConversionPattern' => '[%d] %p %m (%c:%L)%n',
  'log4j.appender.file' => 'org.apache.log4j.RollingFileAppender',
  'log4j.appender.file.maxBackupIndex' => 10,
  'log4j.appender.file.maxFileSize' => '100MB',
  'log4j.appender.file.File' => '${kafka-rest.log.dir}/kafka-rest.log',
  'log4j.appender.file.layout' => 'org.apache.log4j.PatternLayout',
  'log4j.appender.file.layout.ConversionPattern' => '[%d] %p %m (%c)%n'
}

# Kafka Rest CLI configuration (see kafka cli_opts for documentation)
default[cookbook_name]['rest']['cli_opts'] = {
  '-Xms1g' => '',
  '-Xmx1g' => '',
  '-XX:+UseG1GC' => '',
  '-XX:MaxGCPauseMillis' => 20,
  '-XX:InitiatingHeapOccupancyPercent' => 35,
  '-Dcom.sun.management.jmxremote' => '',
  '-Dcom.sun.management.jmxremote.authenticate' => false,
  '-Dcom.sun.management.jmxremote.ssl' => false,
  '-Dcom.sun.management.jmxremote.port' => 8092,
  '-Djava.rmi.server.hostname' => node['fqdn']
}

# Rest Systemd service unit, can include all JVM options in ExecStart
cp = %w[confluent-common rest-utils kafka-rest].map do |path|
  "/usr/share/java/#{path}/*"
end.join(':')

default[cookbook_name]['rest']['unit'] = {
  'Unit' => {
    'Description' =>
      'The Kafka REST Proxy provides a RESTful interface to a Kafka',
    'After' => 'network.target'
  },
  'Service' => {
    'User' => node[cookbook_name]['rest']['user'],
    'Group' => node[cookbook_name]['rest']['group'],
    'SyslogIdentifier' => 'kafka-rest',
    'Restart' => 'on-failure',
    'ExecStart' => {
      'start' => '/usr/bin/java',
      'end' =>
        '-Dlog4j.configuration=file:/etc/kafka-rest/log4j.properties ' \
        "-cp #{cp} " \
        'io.confluent.kafkarest.Main ' \
        '/etc/kafka-rest/kafka-rest.properties'
    }
  },
  'Install' => {
    'WantedBy' => 'multi-user.target'
  }
}

# Kafka Connect configuration
default[cookbook_name]['connect']['user'] = 'cp-kafka-connect'
default[cookbook_name]['connect']['group'] = 'confluent'
# Restart service at configuration changes
default[cookbook_name]['connect']['auto_restart'] = false

default[cookbook_name]['connect']['log4j'] = {
  'log4j.rootLogger' => 'INFO, stdout',
  'log4j.appender.stdout' => 'org.apache.log4j.ConsoleAppender',
  'log4j.appender.stdout.layout' => 'org.apache.log4j.PatternLayout',
  'log4j.appender.stdout.layout.ConversionPattern' => '[%d] %p %m (%c:%L)%n',
  'log4j.logger.org.apache.zookeeper' => 'ERROR',
  'log4j.logger.org.I0Itec.zkclient' => 'ERROR',
  'log4j.logger.org.reflections' => 'ERROR'
}

# Unit and cli options
default[cookbook_name]['connect']['cli_opts'] = {}
default[cookbook_name]['connect']['unit'] = {
  'Unit' => {
    'Description' => 'Kafka Connect',
    'After' => 'network.target'
  },
  'Service' => {
    'User' => node[cookbook_name]['connect']['user'],
    'Group' => node[cookbook_name]['connect']['group'],
    'SyslogIdentifier' => 'kafka-connect',
    'Restart' => 'on-failure',
    'RestartSec' => 5,
    'ExecStart' => {
      'start' => '/usr/bin/connect-distributed',
      'end' => '/etc/kafka/connect-distributed.properties'
    }
  },
  'Install' => {
    'WantedBy' => 'multi-user.target'
  }
}

# Kafka Connect Daemon configuration
default[cookbook_name]['connect']['config'] = {
  'bootstrap.servers' => 'localhost:9092', # will be replaced by a search
  'group.id' => 'connect-cluster',
  'key.converter' => 'org.apache.kafka.connect.json.JsonConverter',
  'value.converter' => 'org.apache.kafka.connect.json.JsonConverter',
  'key.converter.schemas.enable' => true,
  'value.converter.schemas.enable' => true,
  'config.storage.topic' => 'connect-configs',
  'config.storage.replication.factor' => 1,
  'offset.storage.topic' => 'connect-offsets',
  'offset.storage.replication.factor' => 1,
  'offset.storage.partitions' => 25,
  'status.storage.topic' => 'connect-status',
  'status.storage.replication.factor' => 1,
  'status.storage.partitions' => 5,
  'offset.flush.interval.ms' => 10_000,
  'plugin.path' => '/usr/share/java,/usr/share/confluent-hub-components'
}

# Connectors to install from Confluent Hub
# Update are NOT automatic! (due to confluent-hub-client itself)
default[cookbook_name]['connect']['components'] = {
  # format: 'owner/name' => 'version'
  # 'confluentinc/kafka-connect-elasticsearch' => 'latest'
}

# Jobs to load in Kafka Connect daemon with via REST API
default[cookbook_name]['connect']['connectors'] = {
  # 'job_name' => {
  #   'connector" => 'job_name', # name attribute
  #   'config' => {
  #     'group.id' => 'your_group_id',
  #     'connector.class' => 'com.example.Yourclass',
  #     'tasks.max' => 1,
  #     'topics' => 'if_it_is_a_sink'
  #   },
  #   'url' => 'http://localhost:8083', # be sure to add http or https
  #   'action' => 'create' # or delete, pause, resume, restart
  # },

  # Example with Elastic Search
  # 'elasticsearch-sink' => {
  #   'config' => {
  #     'sink' => {
  #       'connector.class' =>
  #         'io.confluent.connect.elasticsearch.ElasticsearchSinkConnector',
  #       'tasks.max' => 1,
  #       'topics' => 'elasticsearch-sink',
  #       'key.ignore' => true,
  #       'connection.url' => 'http://localhost:9200',
  #       'type.name' => 'kafka-connect'
  #     }
  #   },
  #   'action' => 'create'
  # }
}

# Configure retries for the package resources, default = global default (0)
# (mostly used for test purpose)
default[cookbook_name]['package_retries'] = nil
