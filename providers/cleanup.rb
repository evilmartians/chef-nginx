#
# Cookbook Name:: nginx
# Provider:: cleanup
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

action :run do
  Chef::Log.info("#{new_resource} Disabling up unmanaged Nginx configurations")

  kill_them_with_fire = []

  %w(site stream).each do |section|

    path = ::File.join(new_resource.path, "#{section}s-enabled", '*')
    file_list = ::Dir.glob(path)

    protected_resources = run_context.resource_collection.all_resources.select do |resource|
      resource.resource_name == "#{new_resource.cookbook_name}_#{section}".to_sym
    end

    protected_files = protected_resources.map do |resource|
      ::File.join(new_resource.path, "#{section}s-enabled", "#{resource.name}.conf")
    end

    # Many many thanks to @whitequark for answering my dump questions about ruby!
    kill_them_with_fire += file_list - protected_files
  end

  kill_them_with_fire.each do |file|
    Chef::Log.info("Nginx configuration '#{file}' is not managed by Chef. Disabling it.")
    ::File.unlink file
  end

  new_resource.updated_by_last_action(true) unless kill_them_with_fire.empty?
end

action :disable do
  Chef::Log.info("#{new_resource} is disabled. Here be dragons!!! All unknown configuration files/symlink inside 'sites-enabled' directory will be left as is!!!")
end

# vim: ts=2 sts=2 sw=2 sta et
