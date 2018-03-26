#
# Cookbook Name:: nginx
# Resource:: site
# Resource:: stream
#
# Author:: Kirill Kouznetsov
#
# Copyright 2018, Kirill Kouznetsov.
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

provides :nginx_site
provides :nginx_stream

default_action :enable

property :template, String
property :variables, Hash, default: {}
property :cookbook, String

def to_s
  "#{declared_type}[#{name}]"
end

action_class.class_eval do
  def load_current_resource
    prefix = case new_resource.declared_type
             when :nginx_site
               'sites'
             when :nginx_stream
               'streams'
             end

    @config = ::File.join(
      node['nginx']['config']['conf_dir'],
      "#{prefix}-available",
      "#{name}.conf",
    )

    @symlink = ::File.join(
      node['nginx']['config']['conf_dir'],
      "#{prefix}-enabled",
      "#{name}.conf",
    )
  end
end

action :create do
  unless ::File.exist? @config
    Chef::Log.info("Creating #{new_resource} config.")
  end

  template_file = if new_resource.template.nil? or new_resource.template.empty?
                    "#{new_resource.name}.conf.erb"
                  else
                    new_resource.template
                  end

  if ::File.symlink? @symlink
    declare_resource(:template, @config) do
      action :create
      mode '0644'
      owner 'root'
      group 'root'
      source template_file
      cookbook new_resource.cookbook if new_resource.cookbook
      variables new_resource.variables
      notifies :reload, 'service[nginx]', :delayed
    end
  else
    declare_resource(:template, @config) do
      action :create
      mode '0644'
      owner 'root'
      group 'root'
      source template_file
      cookbook new_resource.cookbook if new_resource.cookbook
      variables new_resource.variables
    end
  end
end

action :enable do
  unless ::File.symlink? @symlink
    Chef::Log.info("Enabling #{new_resource} config.")
  end

  action_create

  resources = run_context.parent_run_context.resource_collection

  if new_resource.declared_type == :nginx_stream
    nginx_main_config_template = resources.find(
      template: 'Nginx main configuration file',
    )
    nginx_main_config_template.variables[:options]['stream_section'] = true
  end

  # link resource sees `@config` as its own insctance variable.
  link_to = @config

  link @symlink do
    action :create
    to link_to
    owner 'root'
    group 'root'
    notifies :reload, 'service[nginx]', :delayed
  end
end

action :disable do
  if ::File.symlink? @symlink
    Chef::Log.info("Disabling #{new_resource} config.")

    link @symlink do
      action :delete
      notifies :reload, 'service[nginx]', :delayed
    end
  end
end

action :delete do
  if ::File.exist? @config
    Chef::Log.info("Deleting #{new_resource} config.")

    action_disable

    file @config do
      action :delete
    end
  end
end
