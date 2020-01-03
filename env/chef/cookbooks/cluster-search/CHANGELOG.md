Changelog
=========

1.5.0
-----

Main:

- feat: make search attribute ('role') configurable
  + Add an attribute to configure the searchable attribute (default "role")
    to allow search on "role:something" (instead of "roles:something"):
    defining a "role" attribute was conflicting with "role" search.

Tests:

- use .gitlab-ci.yml template [20180209]
- replace obsolete require\_chef\_omnibus config

Misc:

- style: fix rubocop offense on re-enable cop
- chore: add 2018 to copyright notice

1.4.0
-----

Main:

- fix: apply custom output also to current node

Tests:

- use .gitlab-ci.yml template [20170712]
- add a test case on custom output for current node

1.3.1
-----

Main:

- #5: fix: size may be invalid if check is deactivated

1.3.0
-----

Main:

- #4: deactivate size check if size is undefined or set to zero
- #3: allow passing a block to apply on results to output ipaddresses or else

Tests:

- use .gitlab-ci.yml template [20170529]
- add build\_pull to download latest image

Misc:

- add chef\_version 12.14 & centos in metadata
- foodcritic: fix license format in metadata
- use karma for git format in contributing

1.2.0
-----

Main:

- issue #1: search nodes within the same environment

Tests:

- Use kitchen-docker\_cli instead of kitchen-docker
- Use continuous integration with gitlab-ci
- Up-to-date kitchen.yml (image, no preparation, always use latest deps, etc.)
- Use gitlab-ci config template (20170202)

Misc:

- Use cookbook\_name alias instead of cluster\_search
- Handover maintenance to chef-platform group, change urls and maintainer

1.1.1
-----

- Fix markdown in changelog

1.1.0
-----

Misc:

- Switch kitchen driver to docker\_cli
- Fix all rubocop offenses
- Add Apache 2 License file
- Move changelog and contributing section from README to external files
- Clean headers

1.0.0
-----

- Initial version, tested with full kitchen suites
