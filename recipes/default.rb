# vim: ts=2 sts=2 sw=2 et sta
#
# Cookbook Name:: nginx
# Recipe:: default
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

begin
  this_recipe_resource_collection = run_context.resource_collection.all_resources.select do |res|
    res.cookbook_name == cookbook_name && res.recipe_name == 'default'
  end

  Chef::Log.debug("Resources found inside recipe[#{cookbook_name}::#{recipe_name}]: #{this_recipe_resource_collection.length}")
  fail Chef::Exceptions::ResourceNotFound if this_recipe_resource_collection.length == 0
rescue Chef::Exceptions::ResourceNotFound
  execute 'kill nginx after installation' do
    command '/usr/bin/pkill nginx'
    action :nothing
    notifies :start, 'service[nginx]'
  end

  package 'nginx' do
    notifies :run, 'execute[kill nginx after installation]'
  end

  directory node['nginx']['directories']['log_dir'] do
    mode '0755'
    owner node['nginx']['user']
    action :create
  end

  %w(nxensite nxdissite).each do |nxscript|
    template "/usr/sbin/#{nxscript}" do
      source "#{nxscript}.erb"
      mode '0755'
      owner 'root'
      group 'root'
    end
  end

  %w(sites-available sites-enabled streams-available streams-enabled conf.d).each do |dir|
    directory dir do
      path "#{node['nginx']['directories']['conf_dir']}/#{dir}/"
      owner 'root'
      group 'root'
      mode '0755'
    end
  end

  # Temporary fix:
  # conf.d/default.conf
  # conf.d/example_ssl.conf
  # These files are installed automatically from nginx package. They
  # may create a conflict with your actual configuration.g
  %w(default example_ssl).each do |f|
    file "#{node['nginx']['directories']['conf_dir']}/conf.d/#{f}.conf" do
      action :delete
    end
  end

  directory '/var/www/' do
    path '/var/www/'
    owner 'root'
    group 'root'
    mode '0755'
  end

  cookbook_file '/var/www/index.html' do
    action :create_if_missing
    source 'welcome-to-nginx.html'
  end

  service 'nginx' do
    supports status: true, restart: true, reload: true
    action [:enable, :start]
  end

  execute 'Generate descent DH param file.' do
    command "openssl dhparam -out #{node['nginx']['directories']['conf_dir']}/dhparam.pem #{node['nginx']['dhparam']['size']}"
    creates "#{node['nginx']['directories']['conf_dir']}/dhparam.pem"
    action :run
    notifies :reload, resources(service: 'nginx'), :delayed
  end

  template 'Nginx main configuration file' do
    path "#{node['nginx']['directories']['conf_dir']}/nginx.conf"
    source 'nginx.conf.erb'
    action :nothing
    owner 'root'
    group 'root'
    variables(
      options: Mash.new(
        'stream_section'       => false,
        'user'                 => node['nginx']['user'],
        'worker_processes'     => node['nginx']['worker_processes'],
        'error_log'            => ::File.join(node['nginx']['directories']['log_dir'], 'error.log'),
        'pid'                  => '/var/run/nginx.pid',
        'conf_dir'             => node['nginx']['directories']['conf_dir'],
        'worker_connections'   => node['nginx']['worker_connections'],
        'worker_rlimit_nofile' => node['nginx']['worker_rlimit_nofile'],
        'log_dir'              => node['nginx']['directories']['log_dir'],
        'mainconfig_include'   => node['nginx']['mainconfig_include']
      )
    )
    notifies :reload, resources(service: 'nginx'), :delayed
  end

  cookbook_file "#{node['nginx']['directories']['conf_dir']}/mime.types" do
    owner 'root'
    group 'root'
    mode '0644'
    source 'mime.types'
    notifies :reload, resources(service: 'nginx'), :delayed
  end

  nginx_cleanup "#{node['nginx']['directories']['conf_dir']}" do
    action :nothing
    notifies :reload, resources(service: 'nginx'), :delayed
  end

  bash 'dummy delay for nginx_cleanup and nginx main config template' do
    code 'true'

    # We want cleanup to happen after all resource invokations from recipes.
    notifies :run, "nginx_cleanup[#{node['nginx']['directories']['conf_dir']}]", :delayed

    # We modify options using resource search from inside NginxSite provider.
    # But template resource from outside provider is already finished its action.
    # So we have to set action to :nothing and trigger template creation later.
    notifies :create, 'template[Nginx main configuration file]', :delayed
  end

  nginx_logrotate_template 'nginx' do
    logs "#{node['nginx']['directories']['log_dir']}/*.log"
    how_often 'daily'
    rotate 7
    copytruncate false
    delaycompress true
    user 'root'
    group 'adm'
    mode '0640'
    pidfile '/var/run/nginx.pid'
  end
end
