Changelog
=========

1.7.0
-----

Main:

- feat: change default log4j logger to CONSOLE
- feat: use zookeeper 3.4.12 by default

Tests:

- test: replace deprecated require\_chef\_omnibus
- test: include .gitlab-ci.yml from test-cookbook

Misc:

- chore: add 2018 to copyright notice
- style(rubocop): fix UnneededCopDisableDirective
- style(rubocop): fix heredoc & log4j config
- chore: rm molinillo constraint in Gemfile

1.6.0
-----

Main:

- fix: allow to not install java package
- fix: setting java attr to "" works as expected
- fix: do not set retries if package\_retries is nil

Tests:

- use .gitlab-ci.yml template [20170731]
- force molinillo version to fix berkshelf

Misc:

- set new contributing guide

1.5.0
-----

Main:

- Handover maintainance to Make.org
- Switch zookeeper version to 3.4.10 by default

Tests:

- Fix destroying in kitchen\_command, stop forcing converge when verify
- Set always\_update and build\_pull in kitchen config
- Use latest template for .gitlab-ci.yml [20170405]

Misc:

- Use cookbook\_name alias everywhere
- Fix recent rubocop offenses
- Fix metadata: license and chef\_version
- Fix nologin shell for zookeeper user

1.4.0
-----

Main:

- Make Systemd unit path configurable, change default to
  "/etc/systemd/system" as recommended by official documentation

Test:

- Start Continuous Integration with gitlab-ci, use templated config
- Add retry on package installations
- Use skip\_preparation: true (image works without modification)
- security\_opt: seccomp=unconfined (enable systemd on recent version)
- Use instance\_host\_name which change node hostnames, adapt tests
- Set package retries to 1 in tests
- Abort cleanly if config is not ok (not enough node found)

Misc:

- Rewrite changelog in markdown

1.3.0
-----

Main:

- Update default zookeeper version to 3.4.8

Tests:

- Use a special docker image, switch to docker\_cli
  + Switch kitchen driver from docker to docker\_cli
  + Use sbernard/centos-systemd-kitchen image instead of bare centos
  + Remove privileged mode :)
  + Remove some now useless monkey patching
  + Clean .kitchen.yml
- No need for dnsdock anymore! (need docker 1.10)
  + Create kitchen network if missing
- Fix cases when cluster is temporarily not connected by trying multiple times
- Fix case "creation of /kitchen" when done twice
- Remove dependency on zookeeper gem

Misc:

- Fix rubocop offenses in kitchen\_command
- Give a specific name to resource to avoid cloning

1.2.0
-----

- Update default zookeeper version to 3.4.7
- Use Apache archive as mirror (to allow all versions)
- Change jmx port to 2191 (2181+10) & force hostname
- Rationalize docker provision to limit number of images
  + Unify the provision command of centos 7 and dnsdock images among the
    different projects so that they can share the docker cache and limit
    the number of images
  + Fix docker image for centos 7.2.1511 (add iproute)
- Fix rubocop offences except for monkey patches
  + Potential breaking change (minor effect), rename:
    - recipes/create-user.rb -> recipes/create\_user.rb
    - recipes/systemd-service.rb -> recipes/systemd\_service.rb
- Use a shorter expression in zookeeper.service

1.1.0
-----

- Make JVM options and Log4j properties configurable
- Fix a typo breaking the auto-restart when zoo.cfg is modified
- Reorganize README:
  + Move changelog from README to CHANGELOG
  + Move contribution guide to CONTRIBUTING.md
  + Reorder README
- Add Apache 2 license file

1.0.0
-----

- Initial version with Centos 7 support
