# frozen_string_literal: true

name 'confluent-platform'
maintainer 'Chef Platform'
maintainer_email 'incoming+chef-platform/confluent-platform@'\
  'incoming.gitlab.com'
license 'Apache-2.0'
description 'Install and configure Confluent platform (Kafka)'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
source_url 'https://gitlab.com/chef-platform/confluent-platform'
issues_url 'https://gitlab.com/chef-platform/confluent-platform/issues'
version '3.3.0'

chef_version '>= 12.14'

supports 'centos', '>= 7.1'

depends 'cluster-search'
