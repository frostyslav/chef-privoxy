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

version = node[:privoxy][:version]
install_path = "#{node[:privoxy][:exec_prefix_dir]}/sbin/privoxy"

directory "/var/log/privoxy" do
  owner node[:privoxy][:user]
  group node[:privoxy][:group]
  mode  00755
  action :create
end

remote_file "#{Chef::Config[:file_cache_path]}/privoxy-#{version}.tar.gz" do
  source   "#{node[:privoxy][:url]}/privoxy-#{version}-stable-src.tar.gz"
  checksum node[:privoxy][:checksum]
  mode     00644
end

configure_options = node[:privoxy][:configure_options].join(" ")
privoxy_install = false

if File.exists?(install_path)
  cmd = Mixlib::ShellOut.new(node[:version_check][:command])
  cmd.run_command
  matches = cmd.stdout.downcase.squeeze(' ').match(/version\s?: ([0-9\.]+)/)
  current_version = matches[1]
  if Gem::Version.new(version) > Gem::Version.new(current_version)
    privoxy_install = true
  end
else
  privoxy_install = true
end

bash "build-and-install-privoxy" do
  cwd Chef::Config[:file_cache_path]
  code <<-EOF
  mkdir privoxy-#{version}
  tar --extract --file=privoxy-#{version}.tar.gz --strip-components=1 --directory=privoxy-#{version}
  (cd privoxy-#{version} && autoheader && autoconf && ./configure #{configure_options})
  (cd privoxy-#{version} && make && checkinstall #{node[:checkinstall][:options]})
  chown -R #{node[:privoxy][:user]}:#{node[:privoxy][:group]} #{node[:privoxy][:config_dir]}
  EOF
  not_if { privoxy_install == false }
end
