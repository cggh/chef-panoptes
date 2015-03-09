#
# Cookbook Name:: panoptes
# Recipe:: default
#
# Copyright 2015, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
include_recipe "panoptes::mysql_server"
include_recipe "panoptes::apache"
include_recipe "panoptes::base"

