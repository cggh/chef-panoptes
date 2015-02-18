#
# Cookbook Name:: panoptes
# Recipe:: default
#
# Copyright 2015, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
include_recipe 'apache2'
include_recipe "apache2::mod_wsgi"
include_recipe "python"

connection_info = {:host => node["panoptes"]["database_server"], :username => 'root', :password => node['mysql']['server_root_password']}


directory node["panoptes"]["database_data_dir"] do
  owner "mysql"
  group "mysql"
  mode "0700"
  action :create
  recursive true
end

directory node["panoptes"]["database_tmp_dir"] do
  owner "mysql"
  group "mysql"
  mode "0755"
  action :create
  recursive true
end

mysql_service 'default' do
  port '3306'
  data_dir node['panoptes']['database_data_dir']
  version '5.6'
  initial_root_password node['mysql']['server_root_password']
  action [:create,:start]
end

mysql2_chef_gem 'default' do
  client_version '5.6'
  action :install
end

mysql_config 'default' do
  source 'panoptes.cnf.erb'
  variables(:tmpdir => node['panoptes']['database_tmp_dir'], :buffer_pool_size => node['panoptes']['database_buffer_pool_size'])
  notifies :restart, 'mysql_service[default]'
  action :create
end

mysql_database node['panoptes']['database'] do
  connection connection_info
  action :create
end

mysql_database_user node['panoptes']['db_username'] do
  connection connection_info
  password node['panoptes']['db_password']
  database_name node['panoptes']['database']
  privileges [:select,:update,:insert,:create,:delete]
  action :grant
end

mysql_client 'default' do
  version '5.6'
  action :create
end

web_app 'panoptes' do
  template 'site.conf.erb'
  docroot install_dir
  server_name node['panoptes']['server_name']
end

panoptes_install = Chef::Config[:file_cache_path] + "/" + node['panoptes']['version'] + ".tar.gz"

remote_file panoptes_install do
  source "https://github.com/cggh/panoptes/archive/" + node['panoptes']['version'] + ".tar.gz"
  mode "0644"
end

user node["panoptes"]["user"] do
  uid node["panoptes"]["uid"]
  password node["panoptes"]["password"]
  home node["panoptes"]["home"]
  shell '/bin/bash'
  action :create
end

install_dir = node["panoptes"]["home"] + node["panoptes"]["path"]
directory install_dir do
  owner node["panoptes"]["user"]
  group "www-data"
  mode "0755"
  action :create
  recursive true
end

execute "untar-panoptes" do
  cwd install_dir
  user node["panoptes"]["user"]
  command "tar --strip-components 1 -xzf " + panoptes_install
end

virtualenv = install_dir + "/build/virtualenv"
build_dir = install_dir + "/build"

directory build_dir do
  owner node["panoptes"]["user"]
  group "www-data"
  mode "0755"
  action :create
  recursive true
end

python_virtualenv virtualenv do
  interpreter "python2.7"
  owner node["panoptes"]["user"]
  group "www-data"
  action :create
end

python_pip "numpy" do
  virtualenv virtualenv
  version "1.9.1"
  user node["panoptes"]["user"]
  group "www-data"
  action :install
end

apt_package "libhdf5-serial-dev" do
  action :install
end

git build_dir + "/DQX" do
  repository 'https://github.com/cggh/DQX.git'
  revision node["panoptes"]["DQX"]["version"]
  action :sync
end

git build_dir + "/DQXServer" do
  repository 'https://github.com/cggh/DQXServer.git'
  revision node["panoptes"]["DQXServer"]["version"]
  action :sync
end

template install_dir + "/config.py" do
  source "config.py.erb"
  owner node["panoptes"]["user"]
  variables(
    :db_server_name => node["panoptes"]["database_server"],
    :db_user => node["panoptes"]["db_username"],
    :db_pass => node["panoptes"]["db_password"],
    :db_name => node["panoptes"]["database"],
    :source_dir => node["panoptes"]["source_dir"],
    :base_dir => node["panoptes"]["base_dir"],
    :auth_file => node["panoptes"]["auth_file"],
    :cas_service => node["panoptes"]["cas"]["service"],
    :cas_logout => node["panoptes"]["cas"]["logout"],
    :cas_url => node["panoptes"]["cas"]["url"])
  group "www-data"
  sensitive true
  action :create_if_missing
end


bash "install_website" do
  code "./scripts/build.sh"
#  user node["panoptes"]["user"]
  cwd install_dir
end

