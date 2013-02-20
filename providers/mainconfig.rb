#
# Cookbook Name:: nginx
# Provider:: mainconfig
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

action :create do
  # Only the last invocation of this resource should, in fact, do things.
  res = run_context.resource_collection.all_resources.select do |resource|
    resource.resource_name == new_resource.resource_name
  end.last

  if res == new_resource
    Chef::Log.info("#{new_resource} Configuring '#{node['nginx']['directories']['conf_dir']}/nginx.conf'")
    config_template = template "#{node['nginx']['directories']['conf_dir']}/nginx.conf" do
      action :create
      owner "root"
      group "root"
      cookbook new_resource.cookbook_name.to_s
      source new_resource.template
      variables new_resource.variables
      notifies :reload, resources(:service => "nginx"), :delayed
    end

    if config_template.updated_by_last_action?
      new_resource.updated_by_last_action(true)
    end

    number_of_invocations = run_context.resource_collection.all_resources.count do |resource|
      resource.resource_name == new_resource.resource_name
    end

    if number_of_invocations > 2
      res = run_context.resource_collection.all_resources.select do |resource|
        resource.resource_name == new_resource.resource_name
      end[1..-2].map do |resource|
        "#{resource.resource_name}[#{resource.name}]"
      end.join(", ")

      Chef::Log.info("ATTENTION!!! Resource #{new_resource.resource_name}[...] is invoked for #{number_of_invocations} time. Only the last invokation actually make changes.")
      Chef::Log.info("ATTENTION!!! Please consider removing this invocations: #{res}")
    end

  else
    Chef::Log.info("#{new_resource} Skipping.")
    Chef::Log.debug("#{res} != #{new_resource} Skipping run of #{new_resource}.")
  end

end

# vim: ts=2 sts=2 sw=2 sta et
