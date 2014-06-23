#
# Cookbook Name:: nginx
# Provider:: confd
#
# Author:: Kirill Kouznetsov
#
# Copyright 2013, Kirill Kouznetsov.
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

def load_current_resource
  @confd_template = run_context.resource_collection.find(template: confd_full_file_name(new_resource.name))
rescue Chef::Exceptions::ResourceNotFound => e
  Chef::Log.info(e.message)
  @confd_template = template confd_full_file_name(new_resource.name) do
    owner 'root'
    group 'root'
    mode 0644
    source 'confd.erb'
    variables(nginx_params: Mash.new)
  end
end

action :create do
  Chef::Log.warn("Creating #{new_resource}")
end

private

def confd_full_file_name(name)
  ::File.join(node['nginx']['directories']['conf_dir'], 'conf.d', "#{name}.conf")
end
