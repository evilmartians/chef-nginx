#
# Cookbook Name:: nginx
# Provider:: site_untracked
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

provides :nginx_stream

def initialize(new_resource, run_context)
  super(new_resource, run_context)

  @config = "#{node['nginx']['directories']['conf_dir']}/#{new_resource.prefix}-available/#{new_resource.name}.conf"
  @symlink = "#{node['nginx']['directories']['conf_dir']}/#{new_resource.prefix}-enabled/#{new_resource.name}.conf"
end

action :create do
  Chef::Log.info("Creating #{new_resource} config.") unless ::File.exist? @config

  template_file = (new_resource.template.nil? || new_resource.template.empty?) ? "#{new_resource.name}.conf.erb" : new_resource.template

  config_template = nil

  if ::File.symlink? @symlink
    config_template = template @config do
      action :create
      mode '0644'
      owner 'root'
      group 'root'
      source template_file
      cookbook new_resource.cookbook if new_resource.cookbook
      variables new_resource.variables
      notifies :reload, resources(service: 'nginx'), :delayed
    end
  else
    config_template = template @config do
      action :create
      mode '0644'
      owner 'root'
      group 'root'
      source template_file
      cookbook new_resource.cookbook if new_resource.cookbook
      variables new_resource.variables
    end
  end

  if config_template.updated_by_last_action?
    new_resource.updated_by_last_action(true)
  end

end

action :enable do
  Chef::Log.info("Enabling #{new_resource} config.") unless ::File.symlink? @symlink

  action_create

  if new_resource.resource_name == :nginx_stream
    nginx_main_config_template = run_context.resource_collection.find(template: 'Nginx main configuration file')
    nginx_main_config_template.variables[:options]['stream_section'] = true
  end

  link_to = @config

  link_to_config = link @symlink do
    action :create
    to link_to
    owner 'root'
    group 'root'
    notifies :reload, resources(service: 'nginx'), :delayed
  end

  new_resource.updated_by_last_action(link_to_config.updated_by_last_action?)
end

action :disable do
  if ::File.symlink? @symlink
    Chef::Log.info("Disabling #{new_resource} config.")

    link_to_config = link @symlink do
      action :delete
      notifies :reload, resources(service: 'nginx'), :delayed
    end

    if link_to_config.updated_by_last_action?
      new_resource.updated_by_last_action(true)
    end
  end
end

action :delete do
  if ::File.exist? @config
    Chef::Log.info("Deleting #{new_resource} config.")

    action_disable

    site_file = file @config do
      action :delete
    end

    if site_file.updated_by_last_action?
      new_resource.updated_by_last_action(true)
    end
  end
end

# vim: ts=2 sts=2 sw=2 sta et
