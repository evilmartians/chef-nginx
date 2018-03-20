#
# Cookbook Name:: nginx
# Attributes:: default
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

default['nginx']['config']['conf_dir']                = '/etc/nginx'
default['nginx']['config']['log_dir']                 = '/var/log/nginx'
default['nginx']['config']['user']                    = 'www-data'
default['nginx']['config']['worker_processes']        = node['cpu']['total']
default['nginx']['config']['pid']                     = '/var/run/nginx.pid'
default['nginx']['config']['worker_connections']      = 8192
default['nginx']['config']['worker_rlimit_nofile']    = 8192
default['nginx']['config']['mainconfig_include']      = nil

default['nginx']['config']['error_log'] = ::File.join(
  node['nginx']['config']['log_dir'],
  'error.log',
)

default['nginx']['dhparam']['size'] = 2048

# vim: ts=2 sts=2 sw=2 sta et
