Zookeeper Platform
==================

Description
-----------

Apache ZooKeeper is an effort to develop and maintain an open-source server
which enables highly reliable distributed coordination. Learn more about
ZooKeeper on <http://zookeeper.apache.org>.

This cookbook focuses on deploying a Zookeeper cluster via Chef.

Requirements
------------

### Cookbooks and gems

Declared in [metadata.rb](metadata.rb) and in [Gemfile](Gemfile).

### Platforms

A *systemd* managed distribution:
- RHEL Family 7, tested on Centos 7.2

Note: it should work fine on Debian 8 but the official docker image does not
allow systemd to work easily, so it could not be tested.

Usage
-----

### Easy Setup

Create a role `zookeeper-platform` having `recipe['zookeeper-platform']` in its
runlist and setting `node['zookeeper-platform']['role']` to itself. Add this
role in the runlists of the nodes you want to use for your cluster. By default,
you need exactly 3 nodes.

By default, this cookbook installs *openjdk* from the official repositories
*(openjdk 8 on centos 7)* in **systemd\_service** recipe, just before
launching the service. You can deactivate this behavior by setting
`node['zookeeper-platform']['java']` to `""`, or choose your package by setting
the package name in `node['zookeeper-platform']['java'][node[:platform]]`.

### Search

By default, the *config* recipe use a search to find the members of a cluster.
The search is parametrized by a role name, defined in attribute
`node['zookeeper-platform']['role']` which default to *zookeeper-platform*.
Node having this role in their expanded runlist will be considered in the same
zookeeper cluster. For safety reason, if search is used, you need to define
`node['zookeeper-platform']['size']` (3 by default). The cookbook will return
(with success) until the search return *size* nodes. This ensures the
stability of the configuration during the initial startup of a cluster.

If you do not want to use search, it is possible to define
`node['zookeeper-platform']['hosts']` with an array containing the hostnames of
the nodes of a zookeeper cluster. In this case, *size* attribute is ignored
and search deactivated.

### Test

This cookbook is fully tested through the installation of a working 3-nodes
cluster in docker hosts. This uses kitchen (>= 1.5.0), docker (>= 1.10) and
a small monkey-patch.

For more information, see *.kitchen.yml* and *test* directory.

### Local cluster

You can also use this cookbook to install a zookeeper cluster locally. By
running `kitchen converge`, you will have a 3-nodes cluster available on your
workstation, each in its own docker host. You can then access it with:

    zkCli.sh -server $(docker inspect \
      --format '{{.NetworkSettings.Networks.kitchen.IPAddress}}' \
      zookeeper-kitchen-01)

Attributes
----------

Configuration is done by overriding default attributes. All configuration keys
have a default defined in [attributes/default.rb](attributes/default.rb).
Please read it to have a comprehensive view of what and how you can configure
this cookbook behavior.

Recipes
-------

### default

Run *install*, *create\_user*, *config* and *systemd\_service* recipes, in that
order.

### install

Install zookeeper with *ark* cookbook.

### create\_user

Create zookeeper system user and group.

### config

Generate nodes list by search or by using hosts attribute. Merge it with base
configuration, then install *myid* and *zoo.cfg* files. Create work
directories: for data and logs.

### systemd\_service

Install zookeeper service for systemd, enable and start it. Install *java*
package by default.

Resources/Providers
-------------------

None.

Changelog
---------

Available in [CHANGELOG](CHANGELOG).

Contributing
------------

Please read carefully [CONTRIBUTING.md](CONTRIBUTING.md) before making a merge
request.

License and Author
------------------

- Author:: Samuel Bernard (<samuel.bernard@gmail.com>)

```text
Copyright (c) 2015-2016 Sam4Mobile, 2017-2018 Make.org

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
