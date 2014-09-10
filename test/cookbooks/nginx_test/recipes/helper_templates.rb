#
# Cookbook Name:: nginx_test
# Recipe:: helper_templates
#
# Copyright (C) 2014 Kirill Kouznetsov
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

nginx_site '00-gzip-defaults' do
  cookbook 'nginx'
  template 'gzip.conf.erb'
end

nginx_site '01-some-handy-defaults' do
  cookbook 'nginx'
  template 'some-handy-defaults.conf.erb'
  variables(
    sendfile: false,
    tcp_nopush: 'on',
    tcp_nodelay: true,
    server_tokens: 'off',
    keepalive_timeout: false
  )
end

nginx_site '02-some-handy-defaults' do
  cookbook 'nginx'
  template 'some-handy-defaults.conf.erb'
  variables(
    server_tokens: 'on',
    reset_timedout_connection: true
  )
end

nginx_site '03-some-handy-defaults' do
  cookbook 'nginx'
  template 'some-handy-defaults.conf.erb'
end
