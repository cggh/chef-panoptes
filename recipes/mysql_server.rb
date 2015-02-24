#
# Cookbook Name:: panoptes
# Recipe:: mysql_server
#
# Copyright 2015, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

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
  mode "1777"
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

#For the master database - but see below...
mysql_database_user node['panoptes']['db_username'] do
  connection connection_info
  password node['panoptes']['db_password']
  database_name node['panoptes']['database']
  privileges [:select,:update,:insert,:create,:delete]
  action :grant
end

#User needs to be able to create databases so give all perms on all dbs
mysql_database_user node['panoptes']['db_username'] do
  connection connection_info
  password node['panoptes']['db_password']
  action :grant
end

mysql_client 'default' do
  version '5.6'
  action :create
end

