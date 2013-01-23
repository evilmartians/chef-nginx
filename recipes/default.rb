# vim: ts=2 sts=2 sw=2 et sta
#
# Cookbook Name:: nginx
# Recipe:: default
#
# Author:: Kirill Kouznetsov <agon.smith@gmail.com>
#
# Copyright 2012, Kirill Kouznetsov.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

package "nginx"

directory node['nginx']['directories']['log_dir'] do
  mode 0755
  owner node['nginx']['user']
  action :create
end

%w{nxensite nxdissite}.each do |nxscript|
  template "/usr/sbin/#{nxscript}" do
    source "#{nxscript}.erb"
    mode 0755
    owner "root"
    group "root"
  end
end

%w{sites-available sites-enabled conf.d}.each do |dir|
  directory dir do
    path "#{node['nginx']['directories']['conf_dir']}/#{dir}/"
    owner "root"
    group "root"
    mode 0755
  end
end

directory "/var/www/" do
  path "/var/www/"
  owner "root"
  group "root"
  mode 0755
end

cookbook_file "/var/www/index.html" do
  action :create_if_missing
  source "welcome-to-nginx.html"
end

nginx_mainconfig "nginx.conf.erb"

nginx_logrotate_template "nginx" do
  logs "#{node['nginx']['directories']['log_dir']}/*.log"
  how_often "daily"
  rotate 7
  copytruncate false
  user "root"
  group "adm"
  mode "640"
  pidfile "/var/run/nginx.pid"
end

service "nginx" do
  supports :status => true, :restart => true, :reload => true
  action [ :enable, :start ]
end

cookbook_file "#{node['nginx']['directories']['conf_dir']}/mime.types" do
  owner "root"
  group "root"
  mode 0644
  source "mime.types"
  notifies :reload, resources(:service => "nginx"), :delayed
end

nginx_cleanup "#{node['nginx']['directories']['conf_dir']}/sites-enabled/" do
  notifies :reload, resources(:service => "nginx"), :delayed
end
