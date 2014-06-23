#
# Cookbook Name:: nginx
# Resource:: logrotate_template
#
# Author:: Kirill Kouznetsov
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

include Chef::Mixin::Securable

actions :enable, :disable

attribute :name, name_attribute: true, kind_of: String
attribute :logs, kind_of: String, default: '/var/log/nginx/*.log'
attribute :how_often, kind_of: String, default: 'daily', equal_to: %w(daily weekly monthly)
attribute :rotate, kind_of: Integer, default: 7
attribute :copytruncate, kind_of: [TrueClass, FalseClass], default: false
attribute :pidfile, kind_of: String, default: '/var/run/nginx.pid'

def initialize(name, run_context = nil)
  super
  @action = :enable
  @user   = 'root'
  @group  = 'adm'
  @mode   = 0640
end

# vim: ts=2 sts=2 sw=2 sta et
