%w(httpd httpd-devel gcc).each do |pack_name|
  package "Installing #{pack_name}" do 
	package_name "#{pack_name}"
	action :install
  end
end

service 'Starting Web Service' do 
	service_name 'httpd'
	action [ :restart, :enable ]
end