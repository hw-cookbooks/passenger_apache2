include_recipe "build-essential"

case node[:platform]
when "arch"
  package "apache"
when "centos","redhat"
  package "httpd-devel"
  if node['platform_version'].to_f < 6.0
    package 'curl-devel'
  else
    package 'libcurl-devel'
    package 'openssl-devel'
    package 'zlib-devel'
  end
else
  apache_development_package =  if %w( worker threaded ).include? node[:passenger][:source][:apache_mpm]
                                  'apache2-threaded-dev'
                                else
                                  'apache2-prefork-dev'
                                end
  %W( #{apache_development_package} libapr1-dev libcurl4-gnutls-dev ).each do |pkg|
    package pkg do
      action :upgrade
    end
  end
end

gem_package "passenger" do
  version node[:passenger][:version]
end

execute "passenger_module" do
  command 'passenger-install-apache2-module --auto'
  creates node[:passenger][:source][:module_path]
end
