#
# Cookbook Name:: nginx_test
# Recipe:: default
#
# Copyright (C) 2015 Kirill Kouznetsov
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

file 'nginx_site_notification' do
  path '/tmp/nginx_site_notification.txt'
  content 'passed'
  action :nothing
end

nginx_site 'frontend' do
  notifies :create, 'file[nginx_site_notification]'
end

template '/etc/nginx/mainconfig_custom_include.conf' do
  owner 'root'
  group 'root'
  mode '0644'
  source 'test01.conf.erb'
end
