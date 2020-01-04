# Policyfile.rb - Describe how you want Chef Infra Client to build your system.
#
# For more information on the Policyfile feature, visit
# https://docs.chef.io/policyfile.html

# A name that describes what the system you're building with Chef does.
name 'java8'

# Where to find external cookbooks:
default_source :supermarket

# run_list: chef-client will run these recipes in the order specified.
run_list 'chef-client',
          'audit',
          'ssh-hardening',
          'poise-hoist',
          'wmjava8::default'

# Specify a custom source for a single cookbook:
cookbook 'wmjava8', path: '.'

default['prd'] = {
 'audit' => {
 	'profiles' => [
 		{
 			"name" => "DevSec SSH Baseline",
    		"compliance" => "admin/ssh-baseline"
 		}
 	]
 }
}	

# Define audit cookbook attributes
default["audit"]["reporter"] = "chef-server-automate"
