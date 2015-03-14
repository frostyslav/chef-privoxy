#
# Cookbook Name:: privoxy
# Recipe:: source
# Author:: Rostyslav Fridman (<rostyslav.fridman@gmail.com>)
#
# Copyright 2014, Rostyslav Fridman
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe "checkinstall::default"

remote_file "#{Chef::Config['file_cache_path']}/privoxy-#{node['privoxy']['version']}-stable.tar.gz" do
  source   "#{node['privoxy']['url']}/privoxy-#{node['privoxy']['version']}-stable-src.tar.gz"
  checksum node['privoxy']['checksum']
  mode     00644
end

checkinstall_package "privoxy" do
  source_archive "#{Chef::Config['file_cache_path']}/privoxy-#{node['privoxy']['version']}-stable.tar.gz"
  configure_options node['privoxy']['configure_options']
  version node['privoxy']['version']
  autoheader true
  autoconf true
end

directory "/var/log/privoxy" do
  owner node['privoxy']['user']
  group node['privoxy']['group']
  mode  00755
  action :create
end

file "/var/log/privoxy/logfile" do
  owner node['privoxy']['user']
  group node['privoxy']['group']
  mode  00644
  action :create
end

# Privoxy installer doesn't set the correct permissions at the installation time
# and service can't start if the permissions are wrong
execute "change configuration directory owner" do
  command "chown -R #{node['privoxy']['user']}:#{node['privoxy']['group']} #{node['privoxy']['config_dir']}"
  Chef::Log.info "Change privoxy configuration directory owner"
  only_if "ls -l #{node['privoxy']['config_dir']} | grep root"
end
