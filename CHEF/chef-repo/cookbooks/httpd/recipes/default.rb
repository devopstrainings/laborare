#
# Cookbook:: httpd
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.

#package 'Installing HTTPD package' do 
#  package_name [ 'httpd', 'httpd-devel']
#  action :install
#end

#URL='www.google.com'
#puts "#{node['URL']}"
puts "URL = #{node['httpd']['default']['URL']}"

%w(httpd httpd-devel gcc).each do |pack_name|
  package "Installing #{pack_name}" do 
	package_name "#{pack_name}"
	action :install
  end
end

remote_file "#{node['httpd']['default']['TARFILE']}" do
  source "#{node['httpd']['default']['MODJK_URL']}"
  action :create
end

execute 'Extracting tar file' do
  command "tar xf #{node['httpd']['default']['TARFILE']}"
  cwd "#{node['httpd']['default']['LOC']}"
  action :run
  not_if { File.directory?("#{node['httpd']['default']['TARDIR']}") }
end

execute 'Compile mod_jk' do 
  command './configure --with-apxs=/usr/bin/apxs && make && make install'
  cwd "#{node['httpd']['default']['TARDIR']}/native"
  action :run
  not_if { File.exist?("/etc/httpd/modules/mod_jk.so") } 
end

%w(modjk.conf workers.properties).each do |file|
	cookbook_file "/etc/httpd/conf.d/#{file}" do
	  source "#{file}"
	  action :create
	end
end

service 'Starting Web Service' do 
	service_name 'httpd'
	action [ :restart, :enable ]
end


