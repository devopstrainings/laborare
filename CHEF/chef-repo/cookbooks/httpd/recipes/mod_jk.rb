include_recipe 'httpd::install'

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

%w(modjk.conf).each do |file|
	cookbook_file "/etc/httpd/conf.d/#{file}" do
	  source "#{file}"
	  action :create
	end
end

template "/etc/httpd/conf.d/workers.properties" do 
  source 'workers.properties.erb'
  action :create
end


service 'Starting Web Service' do 
	service_name 'httpd'
	action [ :restart, :enable ]
end