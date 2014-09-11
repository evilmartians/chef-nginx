#
# Cookbook Name:: nginx
# Provider:: logrotate_template
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

def initialize(new_resource, run_context)
  super(new_resource, run_context)

  # Make sure we have logratate daemon installed.
  p = package 'logrotate' do
    action :nothing
  end
  p.run_action(:install)
end

action :enable do
  Chef::Log.info("#{new_resource}: Enabling Nginx logrotation.")

  logrotate_template = template "/etc/logrotate.d/#{new_resource.name}" do
    action :create
    owner 'root'
    group 'root'
    source 'logrotate-nginx.erb'
    variables(
      logs:          new_resource.logs,
      how_often:     new_resource.how_often,
      rotate:        new_resource.rotate,
      copytruncate:  new_resource.copytruncate,
      user:          new_resource.user,
      group:         new_resource.group,
      mode:          new_resource.mode,
      pidfile:       new_resource.pidfile,
      dateext:       new_resource.dateext,
      delaycompress: new_resource.delaycompress
    )
  end

  if logrotate_template.updated_by_last_action?
    new_resource.updated_by_last_action(true)
  end

end

action :disable do
  Chef::Log.info("#{new_resource}: deleting /etc/logrotate.d/#{new_resource.name}")

  logrotate_file = file "/etc/logrotate.d/#{new_resource.name}" do
    action :delete
  end

  if logrotate_file.updated_by_last_action?
    new_resource.updated_by_last_action(true)
  end

end

# vim: ts=2 sts=2 sw=2 sta et
