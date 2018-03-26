#
# Cookbook Name:: nginx
# Resource:: cleanup
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

resource_name :nginx_cleanup

default_action :run

property :path, String, name_property: true

action :run do
  valid_files = list_defined_resources(path, run_context.parent_run_context)
  file_list = ::Dir.glob(::File.join(path, '*-enabled', '*'))

  kill_them_with_fire = file_list - valid_files

  kill_them_with_fire.each do |file|
    Chef::Log.info(
      "Nginx configuration '#{file}' is not managed by Chef. Disabling it.",
    )
    ::File.unlink file
  end
end

private

action_class.class_eval do
  private

  def list_defined_resources(path, run_context)
    res_list = run_context.resource_collection.all_resources.select do |res|
      res.resource_name == :nginx_lwrp_site_and_stream
    end
    res_list.map do |res|
      ::File.join(
        path,
        "#{res.declared_type.to_s.split('_')[1]}s-enabled",
        "#{res.name}.conf",
      )
    end
  end
end
