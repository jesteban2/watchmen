# Policyfile.rb - Describe how you want Chef to build your system.
#
# For more information on the Policyfile feature, visit
# https://docs.chef.io/policyfile.html

# A name that describes what the system you're building with Chef does.
name 'watchmen'

# Where to find external cookbooks:
default_source :supermarket

# run_list: chef-client will run these recipes in the order specified.
run_list  'chef-client',
          'audit',
          'ssh-hardening'
# add 'ssh-hardening' to your runlist to fix compliance issues detected by the ssh-baseline profile

# Specify a custom source for a single cookbook:
cookbook 'wmzookeeper', path: 'cookbooks/wmzookeeper'

# Policyfile defined attributes

# Define audit cookbook attributes
default["audit"]["reporter"] = "chef-server-automate"
default["audit"]["profiles"]["zookeeper"] = [
  {
    "name": "DevSec SSH Baseline",
    "compliance": "admin/ssh-baseline"
  }
]
