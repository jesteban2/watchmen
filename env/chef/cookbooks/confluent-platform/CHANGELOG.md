Changelog
=========

3.3.0
-----

Main:

- fix: use no-prompt option for hub installation
- fix: auto\_restart always true (settings not used)
- fix: service creation failed with chef 12

Tests:

- fix: accept chef license
- switch to chefplatform image
- make kitchen.yml config file visible

Misc:

- style(rubocop): use e instead of error / add FrozenStringLiteralComment
- fix: add rspec-core to Gemfile
- style(rubocop): fix array of words offence

3.2.0
-----

Main:

- feat: can manage package upgrade with a version
  + Each component can have a version specified (rpm version). By using
    "latest" (defined as default), it will always upgrade to the latest one.
- feat: support Kafka Connect & connector resource
  + Add support for Kafka Connect running in distributed mode (and not
    stand-alone). Connectors are installed via Confluent Hub
    (www.confluent.io/hub).
  + Add connector resource which can create/update/delete/pause/resume/restart
    a connector.
- feat: add topic resource to create/delete topics (but not update)
- fix: transform custom service resource to library
  + This fixes the "auto-restart" feature. To be consistent with buggy
    behavior, "auto_restart" configurations are set to false by default

Tests:

- test: show unit logs when waiting for a service

Misc:

- fix: restart services only if previously started

3.1.0
-----

Breaking changes: (mostly a fix for 3.0.0)

- default users and groups are differents (ex: cp-kafka instead of kafka)
- change log directory to /var/log/confluent as in the package

Main:

- set default users/group to packages ones

3.0.0
-----

Breaking changes:

- attributes 'rest'/'brokers\_protocol' and 'rest'/'brokers\_port' are
  replaced by 'kafka'/'protocol' and 'kafka'/'port'
- some default configuration values were updated reflecting the latest
  defaults in confluent 5.0
- all schema-registry must be shutdown when switching on
  'kafkastore.bootstrap.servers' configuration

Main:

- feat: use 5.0 & adapt all config by default
- feat: lazy evaluation of configuration variables
- feat: use brokers for bootstrap in schema-registry

Misc:

- feat: use sensitive in templates
- style: fix rubocop EmptyLineAfterGuardClause
- chore: add supermarket category in .category

2.7.0
-----

Main:

- fix: configure ZK port for rest & schema config
- doc: set a better cookbook description

2.6.0
-----

Main:

- feat: set confluent default version to 4.1.0
- fix(debian): update apt repository config
- feat: add bootstrap.servers support in rest proxy (#6)
- feat: make Zookeeper port configurable (#7)
- feat: sort config files by keys

Tests:

- test: include .gitlab-ci.yml from test-cookbook
- test: replace deprecated require\_chef\_omnibus
- test: increase timeouts for shared runners

Misc:

- doc: use doc in git message instead of docs
- style(rubocop): fix Lint/MissingCopEnableDirective
- style(rubocop): remove useless deactivation
- chore: add 2018 to copyright notice
- chore: set generic maintainer & helpdesk email

2.5.0
-----

Breaking changes:

- drop support for Kakfa < 0.9.0

Main:

- feat: use auto-generated broker.id by default
  + Stop using search IDs to set broker.id. Set it by default to -1 to let
    Kafka generates it itself.
  + You can override this behavior by setting kafka/config/broker.id to the
    ID you want for each node.
  + Note: Setting the broker id to -1 should not affect an existing cluster
    that is already running. The auto broker ID generation is only used when
    there is no known broker ID. If you had a previously assigned ID, it
    will keep that ID.

Misc:

- docs: minor fix on kitchen suites description
- test: revert condition on molinillo to be < 0.6.0

2.4.0
-----

Main:

- fix: do not try to create a nil directory (aka do not need to have
  kafka.logs.dir key in kafka/log4j configuration)

Misc:

- style(rubocop): fix latest offences, mostly heredoc delimiters

2.3.0
-----

Main:

- set confluent default version to 3.3.0
- fix(Chef 13): do not set retries if package\_retries is nil
- fix #2: setting java to "" work as expected
- fix #3: nil error when search return to wait nodes

Tests:

- force molinillo to be < 0.6.0 to fix tests
- fix condition to restart a service in tests
- use .gitlab-ci.yml template [20170731]
- strengthen rest test by parsing JSON

Misc:

- change default size for search
- set new contributing guide with karma style

2.2.0
-----

Main:

- Handover maintainance to Make.org
- Use confluent 3.2.1 by default, fix repository
- Fix metadata: license and set correct chef\_version (12.14)
- Remove yum cookbook dependency
- Refactoring services, use systemd\_unit resource
  + Factorize code by using a custom resource

Tests:

- Set build\_pull & always\_update in tests config
- Fix destroy in tests, stop converge in verify
- Use latest template for .gitlab-ci.yml [20170405]
- Fix #1: Fix kitchen tests (nondeterministic)
- Reduce memory usage for tests
- Make tests work in Gitlab CI shared runners

Misc:

- Fix misc rubocop offenses
- Use cookbook\_name alias everywhere

2.1.0
-----

Main:

- Default confluent version to install is set to 3.0
  + Scala version to install is set to 2.11
  + Mandatory option ssl.client.auth is added to registry config
- Make Systemd unit path configurable

Tests:

- Start Continuous Integration with gitlab-ci
- Add security opts for docker, add package retries
- Remove sleep in recipes, wait to strengthen tests

2.0.0
-----

Main:

- Switch to confluent 2.0
- Rename recipes to respect rubocop rules (breaking change)

Tests:

- Switch to docker\_cli, use prepared docker image
  + Switch kitchen driver from docker to docker\_cli
  + Use sbernard/centos-systemd-kitchen image instead of bare centos
  + Remove privileged mode :)
  + Remove some now useless monkey patching
  + Remove dnsdock, use docker DNS (docker >= 1.10)
  + Use "kitchen" network, create it if needed

Misc:

- Fix all rubocop offenses
- Use specific name for resources to avoid cloning
- Add more details on configuration in README

1.2.0
-----

Main:

- Clarify and fix JVM options for services
- Use to\_hash instead of dup to work on node values
- Improve readibility of default system user names

Fixes:

- Fix and clean the creation of Kafka work directories
- Fix zookeeper.connect chroot path

Test:

- Rationalize docker provision to limit images
- Fix typo in roles/rest-kitchen.json name
- Wait 15s after registry start to strengthen tests

Packaging:

- Reorganize README:
  + Move changelog from README to CHANGELOG
  + Move contribution guide to CONTRIBUTING.md
  + Reorder README, fix Gemfile missing
- Add Apache 2 license file
- Add missing chefignore
- Fix long lines in rest and registry templates

1.1.0
-----

- Cleaning, use only dependencies from supermarket

1.0.1
-----

- Set java-1.8.0-openjdk-headless as default java package

1.0.0
-----

- Initial version with Centos 7 support
