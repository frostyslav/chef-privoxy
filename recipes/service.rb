#
# Cookbook Name:: privoxy
# Recipe:: service
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

case node[:platform]
  when "debian", "ubuntu"
    privoxy_init = "privoxy.init.debian.erb"
  when "redhat", "centos", "amazon", "scientific"
    privoxy_init = "privoxy.init.rhel.erb"
end

template "/etc/init.d/privoxy" do
  source privoxy_init
  owner  "root"
  group  "root"
  mode   00744
end

template "/etc/privoxy/config" do
  source "privoxy.conf.erb"
  owner  node[:privoxy][:user]
  group  node[:privoxy][:group]
  mode   00744
  notifies :restart, "service[privoxy]"
end

service "privoxy" do
  action [:enable, :start]
end

if node[:privoxy][:adblockplus_subscription] == true
  template "/etc/privoxy/privoxy-blacklist" do
    source "privoxy-blacklist.erb"
    owner  node[:privoxy][:user]
    group  node[:privoxy][:group]
    mode   00744
  end

  template "/etc/privoxy/privoxy-blocklist.sh" do
    source "privoxy-blocklist.sh.erb"
    owner  node[:privoxy][:user]
    group  node[:privoxy][:group]
    mode   00744
    notifies :restart, "service[privoxy]"
  end

  bash "fill-adblock-lists" do
    cwd node[:privoxy][:config_dir]
    code <<-EOF
    bash #{[:privoxy][:config_dir]}/privoxy-blocklist.sh
    touch #{[:privoxy][:config_dir]}/adblocklists.created
    EOF
    not_if { File.exists?("#{[:privoxy][:config_dir]}/adblocklists.created")}
  end
end
