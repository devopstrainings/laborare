#
# Cookbook:: demo
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.

#puts "MY URL = #{node['URL']}"
#puts "MY TAR = #{node['TAR']}"

include_recipe 'init::default'
log 'message' do
  message 'A message from demo default recipe'
  level :fatal
end
