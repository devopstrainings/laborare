#
# Cookbook:: init
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.
log 'message' do
  message "VALUE = #{node['init']['VAL']}"
  level :fatal
end
