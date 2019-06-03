#
# Cookbook Name:: nginx_test
# Recipe:: cleaner_check
#
# Copyright (C) 2015 Kirill Kouznetsov
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

# rubocop:disable Layout/IndentHeredoc
# rubocop:disable Naming/HeredocDelimiterNaming
file '/etc/nginx/sites-available/20-hahaha.conf' do
  owner 'root'
  group 'root'
  mode '0644'
  content <<-EOF
# This file should be absent!!!

server {
  listen 0.0.0.0:8080;
  server_name _;
  root /var/www/;
  index index.html;
  charset utf-8;
}
  EOF
end

link '/etc/nginx/sites-enabled/20-hahaha.conf' do
  to '/etc/nginx/sites-available/20-hahaha.conf'
end

file '/etc/nginx/streams-enabled/wanked.conf' do
  owner 'root'
  group 'root'
  mode '0644'
  content <<-EOF
# Your system has been officially WANKed!!!.
  EOF
end
# rubocop:enable Layout/IndentHeredoc
# rubocop:enable Naming/HeredocDelimiterNaming
