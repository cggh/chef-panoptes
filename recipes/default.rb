#
# Cookbook Name:: panoptes
# Recipe:: default
#
# Copyright 2015, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
include_recipe 'git'
include_recipe "python"

include_recipe "panoptes::mysql_server"
include_recipe "panoptes::apache"

install_dir = node["panoptes"]["install_root"] + "/" + node["panoptes"]["git"]["revision"]


user node["panoptes"]["user"] do
  uid node["panoptes"]["uid"]
  password node["panoptes"]["password"]
  home node["panoptes"]["home"]
  shell '/bin/bash'
  supports :manage_home => true
  action :create
end

directory node["panoptes"]["install_root"] do
  owner node["panoptes"]["user"]
  group "www-data"
  mode "0755"
  action :create
  recursive true
end

%w{temp SummaryTracks Uploads Docs Graphs 2D_data}.each do |dir_name|
  directory node["panoptes"]["base_dir"] + '/' + dir_name do
    owner node["panoptes"]["user"]
    group "www-data"
    mode "0775"
    action :create
    recursive true
  end
end

git "panoptes" do
  destination install_dir
  repository node["panoptes"]["git_root"] + '/panoptes.git'
  revision node["panoptes"]["git"]["revision"]
  user node["panoptes"]["user"]
#  checkout_branch node["panoptes"]["git"]["branch"]
  action :checkout
end

build_dir = install_dir + "/build"

directory build_dir do
  owner node["panoptes"]["user"]
  group "www-data"
  mode "0755"
  action :create
  recursive true
end

build_ve = install_dir + "/build" + node["panoptes"]["virtualenv"]

python_virtualenv build_ve do
  interpreter "python2.7"
  owner node["panoptes"]["user"]
  group "www-data"
  action :create
end

python_pip "numpy" do
  virtualenv build_ve
  version "1.9.1"
  user node["panoptes"]["user"]
  group "www-data"
  action :install
end

apt_package "libhdf5-serial-dev" do
  action :install
end

git "DQX" do
  destination install_dir + "/webapp/scripts/DQX"
  repository node["panoptes"]["git_root"] + '/DQX.git'
#Can't use this - because file doesn't exist at compile time - if you try and use run_action on git[panoptes] other stuff not there
#  revision ::File.open(install_dir + '/dependencies/DQX_Version').read
  revision node["panoptes"]["git"]["DQX"]["revision"]
#  checkout_branch node["panoptes"]["git"]["DQX"]["branch"]
  user node["panoptes"]["user"]
  action :checkout
end

git "DQXServer" do
  destination build_dir + "/DQXServer"
  repository node["panoptes"]["git_root"] + '/DQXServer.git'
  revision node["panoptes"]["git"]["DQXServer"]["revision"]
#  checkout_branch node["panoptes"]["git"]["DQXServer"]["branch"]
  user node["panoptes"]["user"]
  action :checkout
end

link build_dir + "/DQXServer/customresponders" do
 to install_dir + "/servermodule" 
end

file build_dir + "/DQXServer/customresponders/__init__.py" do
  owner node["panoptes"]["user"]
  group "www-data"
  mode '0644'
  action :create_if_missing
end

link install_dir + "/webapp/Docs" do
  to node["panoptes"]["base_dir"] + "/Docs"
end

directory install_dir + "/webapp/scripts/Local/" do
  owner node["panoptes"]["user"]
  group "www-data"
  mode "0755"
  action :create
  recursive true
end

template install_dir + "/webapp/scripts/Local/_SetServerUrl.js" do
  source install_dir + "/webapp/scripts/Local.example/_SetServerUrl.js"
  local true
  owner node["panoptes"]["user"]
  group "www-data"
  action :create_if_missing
end

link build_dir + "/DQXServer/static" do
  to install_dir + "/webapp"
end

template build_dir + "/DQXServer/config.py" do
  source install_dir + "/config.py.example"
  local true
  owner node["panoptes"]["user"]
  variables(
    :name => node["panoptes"]["name"],
    :db_server_name => node["panoptes"]["database_server"],
    :db_user => node["panoptes"]["db_username"],
    :db_pass => node["panoptes"]["db_password"],
    :db_name => node["panoptes"]["database"],
    :source_dir => node["panoptes"]["source_dir"],
    :base_dir => node["panoptes"]["base_dir"],
    :auth_file => node["panoptes"]["auth_file"],
    :cas_service => node["panoptes"]["cas"]["service"],
    :cas_logout => node["panoptes"]["cas"]["logout"],
    :cas_url => node["panoptes"]["cas"]["url"]
    )
  group "www-data"
  sensitive true
  action :create_if_missing
  notifies :create, 'ruby_block[add-paths]'
end

ruby_block "add-paths" do
  block do
    fe = Chef::Util::FileEdit.new(build_dir + "/DQXServer/config.py")
    fe.insert_line_if_no_match(/pythoncommand/, "pythoncommand='" + build_ve + "/bin/python'")
    fe.insert_line_if_no_match(/mysqlcommand/,  "mysqlcommand='" + "/usr/bin/mysql'")
    fe.write_file
  end
end

python_pip build_dir + "/DQXServer/REQUIREMENTS" do
  virtualenv build_ve
  user node["panoptes"]["user"]
  group "www-data"
  options "-r"
  action :install
end

python_pip install_dir + "/servermodule/REQUIREMENTS" do
  virtualenv build_ve
  user node["panoptes"]["user"]
  group "www-data"
  options "-r"
  action :install
end

link node["panoptes"]["install_root"] + node["panoptes"]["path"] do
 to install_dir
end

ruby_block "Replace name" do
  block do
    sed = Chef::Util::FileEdit.new(install_dir + "/webapp/index.html")
    sed.search_file_replace(/#DEV#/, node["panoptes"]["name"])
    sed.write_file
  end
end
#Done later in case the directory already exists as parent of the git source
directory node["panoptes"]["source_dir"] do
  owner node["panoptes"]["user"]
  group "www-data"
  mode "0755"
  action :create
  recursive true
end

directory node["panoptes"]["base_dir"] do
  owner node["panoptes"]["user"]
  group "www-data"
  mode "0775"
  action :create
  recursive true
end
#bash "install_website" do
#  code "./scripts/build.sh"
#  user node["panoptes"]["user"]
#  cwd install_dir
#end

