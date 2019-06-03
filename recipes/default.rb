#
# Cookbook Name:: nginx
# Recipe:: default
#
# Author:: Kirill Kouznetsov <agon.smith@gmail.com>
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

begin
  all_res = run_context.resource_collection.all_resources

  recipe_res_collection = all_res.select do |res|
    res.cookbook_name == cookbook_name && res.recipe_name == 'default'
  end

  Chef::Log.debug(
    format(
      'Resources found inside recipe[%<cookbook>s::%<recipe>s]: %<resources>s',
      cookbook: cookbook_name,
      recipe: recipe_name,
      resources: recipe_res_collection.length,
    ),
  )
  raise Chef::Exceptions::ResourceNotFound if recipe_res_collection.empty?
rescue Chef::Exceptions::ResourceNotFound
  package 'logrotate'
  package 'nginx'

  # We stop nginx right after the installation to make the first configuration.
  # We will make sure it starts with the dummy delay resource below.
  service 'nginx' do
    action :enable if node['platform'] == 'ubuntu' and
                      node['platform_version'].to_f < 16.04
    subscribes :stop, 'package[nginx]', :immediately
  end

  directory node['nginx']['config']['log_dir'] do
    mode '0755'
    owner node['nginx']['config']['user']
    action :create
  end

  %w[nxensite nxdissite].each do |nxscript|
    template "/usr/sbin/#{nxscript}" do
      source "#{nxscript}.erb"
      mode '0755'
      owner 'root'
      group 'root'
    end
  end

  %w[
    sites-available
    sites-enabled
    streams-available
    streams-enabled
    conf.d
  ].each do |dir|
    directory dir do
      path "#{node['nginx']['config']['conf_dir']}/#{dir}/"
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
  %w[default example_ssl].each do |f|
    file "#{node['nginx']['config']['conf_dir']}/conf.d/#{f}.conf" do
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

  dh_param_path = "#{node['nginx']['config']['conf_dir']}/dhparam.pem"
  dh_param_size = node['nginx']['dhparam']['size']

  execute 'Generate descent DH param file.' do
    command "openssl dhparam -out #{dh_param_path} #{dh_param_size}"
    creates dh_param_path
    action :run
    notifies :reload, 'service[nginx]', :delayed
  end

  template 'Nginx main configuration file' do
    path "#{node['nginx']['config']['conf_dir']}/nginx.conf"
    source 'nginx.conf.erb'
    owner 'root'
    group 'root'
    variables(options: Mash.new(node['nginx']['config']))

    # Start nginx if not started and reload otherwise.
    notifies :start, 'service[nginx]', :delayed
    notifies :reload, 'service[nginx]', :delayed

    # see dummy delay resource below.
    action :nothing
  end

  cookbook_file "#{node['nginx']['config']['conf_dir']}/mime.types" do
    owner 'root'
    group 'root'
    mode '0644'
    source 'mime.types'
    notifies :reload, 'service[nginx]', :delayed
  end

  nginx_cleanup node['nginx']['config']['conf_dir'] do
    action :nothing
    notifies :reload, 'service[nginx]', :delayed
    only_if { node['nginx']['enable_cleanup'] }
  end

  template '/etc/logrotate.d/nginx' do
    owner 'root'
    group 'root'
    source 'logrotate-nginx.erb'
    variables(
      logs: node['nginx']['logrotate']['logs'],
      how_often: node['nginx']['logrotate']['how_often'],
      rotate: node['nginx']['logrotate']['rotate'],
      copytruncate: node['nginx']['logrotate']['copytruncate'],
      user: node['nginx']['logrotate']['user'],
      group: node['nginx']['logrotate']['group'],
      mode: node['nginx']['logrotate']['mode'],
      pidfile: node['nginx']['logrotate']['pidfile'],
      dateext: node['nginx']['logrotate']['dateext'],
      delaycompress: node['nginx']['logrotate']['delaycompress'],
    )
  end

  bash 'custom delay for some resouces' do
    code 'true'

    # We want cleanup to happen after all resource invocations from recipes.
    notifies :run,
             "nginx_cleanup[#{node['nginx']['config']['conf_dir']}]",
             :delayed

    # Delaying nginx.conf creation to help nginx_stream resources enable
    # streams directories includes.
    notifies :create, 'template[Nginx main configuration file]', :delayed
  end
end
