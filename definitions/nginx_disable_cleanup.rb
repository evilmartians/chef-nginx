#
# Cookbook Name:: nginx
# Definition:: nginx_disable_cleanup
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

define :nginx_disable_cleanup do
  res = resources(nginx_cleanup: "#{node['nginx']['directories']['conf_dir']}/sites-enabled/")
  res.action :disable
end

# vim: ts=2 sts=2 sw=2 sta et
