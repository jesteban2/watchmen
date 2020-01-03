#
# Cookbook:: wmjava8
# Recipe:: default
#
# Copyright:: 2019, The Authors, All Rights Reserved.

include_recipe 'java::default'

if node.key?('java') && node['java'].key?('java_home')

  Chef::Log.info("JAVA_HOME = #{node['java']['java_home']}")

  ENV['JAVA_HOME'] = node['java']['java_home']
end
