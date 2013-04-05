#
# Cookbook Name:: nginx
# Definition:: nginx_mainconfig
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

define :nginx_mainconfig do
  if params.has_key?(:options) and (params[:options].kind_of?(Hash) or params[:options].kind_of?(Mash))
    begin
      nginx_main_config_template = @run_context.resource_collection.find({:template => "Nginx main configuration file"})
      params[:options].each do |k,v|
        nginx_main_config_template.variables[:options][k] = v
      end
    rescue Chef::Exceptions::ResourceNotFound => e
      Chef::Log.error("Resource template[Nginx main configuration file] not fond. Skipping nginx_mainconfig invocation from recipe[#{cookbook_name}::#{recipe_name}]")
    end
  end
end