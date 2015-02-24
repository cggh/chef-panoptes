#
# Cookbook Name:: panoptes
# Recipe:: apache
#
# Copyright 2015, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
include_recipe 'apache2'
include_recipe 'apache2::mod-wsgi'

install_dir = node["panoptes"]["home"] + node["panoptes"]["path"]

web_app 'panoptes' do
  template 'site.conf.erb'
  docroot '/var/www/html'
  install_dir install_dir
  server_name node['panoptes']['server_name']
end

# Enable necessary build-in apache modules
%w{actions expires setenvif deflate filter expires rewrite wsgi}.each do |module_name|
  apache_module module_name do
    enable true
  end
end

# Add Google Repository
#apt_repository "google-spdy" do
#  uri "http://dl.google.com/linux/mod-spdy/deb/"
#  distribution "stable"
#  components ["main"]
#  key "https://dl-ssl.google.com/linux/linux_signing_key.pub"
#end

# Install mod_spdy
#package "mod-spdy-beta" do
#  action :install
#end

# Enable it
#apache_module "spdy" do
#  enable true
#end

