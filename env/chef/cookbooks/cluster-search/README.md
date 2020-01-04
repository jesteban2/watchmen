Cluster Search
==============

Description
-----------

Cluster Search (cluster-search) is a simple cookbook library which simplify
the search of members of a cluster. It relies on Chef search with a size guard
(to avoid inconsistencies during initial convergence) and allows a fall-back
to any listing if user does not want to rely on searches (because of
chef-solo for example).

Requirements
------------

None. Should work on any platform.

Usage
-----

First, call `::Chef::Recipe.send(:include, ClusterSearch)` to be able to use
`cluster_search` in your recipe.

Then method `cluster_search` take one argument and an optional block.
The argument is a hash which could contain:

- `role` (the name is configurable by attributes)  and `size` to use search.
  Ex: `{ role: my_search, size: 2 }`
- or `hosts` to use a static list. Ex: `{ hosts: [ some_node ] }`

Note:

- If both are defined, `hosts` is used.
- Size check can be deactivated by not setting it or setting it to zero. It is
  not recommended to disable it when searching for sibling as it can cause
  configuration fluctuations during cluster convergence (first node of the
  cluster to run Chef will find only itself, then two nodes, etc.).

It returns the list of the members of a cluster `hosts` and current node ID
`my_id` for this cluster (or -1 it is not a member). By default (no block
passed), the `hosts` result is a list of FQDN, extracted with `node['fqdn']`.
By passing the block `{ |n| n['ipaddress'] }`, you will get the list of IP
addresses. And so on.

For search, we suppose that all members of a cluster have a common role in
their run-list. For instance, all zookeeper nodes of a dedicated cluster for
kafka could use role *zookeeper-kafka*. By defining `role` to
*zookeeper-kafka* and configuring `size` to the expected size of the cluster,
we can find all the cluster members.

We can find input/output examples (used for test cases) in file
*.kitchen.yml*.

Attributes
----------

Configuration is done by overriding default attributes. All configuration keys
have a default defined in [attributes/default.rb](attributes/default.rb).
Please read it to have a comprehensive view of what and how you can configure
this cookbook behavior.

Libraries
---------

### default

Implements `cluster_search` method.

Recipes
-------

### default

Do nothing

### test

Recipe used for testing.

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
