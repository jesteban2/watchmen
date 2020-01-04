name 'zookeeper-platform'
maintainer 'Make.org'
maintainer_email 'sre@make.org'
license 'Apache-2.0'
description 'Installs/Configures a Zookeeper cluster using systemd'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
source_url 'https://gitlab.com/chef-platform/zookeeper-platform'
issues_url 'https://gitlab.com/chef-platform/zookeeper-platform/issues'
version '1.7.0'

chef_version '>= 12.0'

supports 'centos', '>= 7.1'

depends 'ark'
depends 'cluster-search'
