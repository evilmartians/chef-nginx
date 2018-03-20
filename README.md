# Description

Installs Nginx from package, sets up some default configuration and defines LWRP supposed to be used inside your own cookbooks, which you use to manage your infrastructure.

# Requirements

## Cookbooks

At the moment this cookbook doesn't depend on other cookbooks but it may change in the future.

## Platform

The cookbook has been tested to work on `Ubuntu 14.04`, `Ubuntu 16.04`, `Debian 8` and `Debian 9`

I suppose it should also work for CenOS/RHEL but no tests have been conducted yet.

## Chef version

Chef version >= `13` has to be used.

> Сhef 12 is reaching its EOL in April 2018 and will be removed from [downloads.chef.io](https://downloads.chef.io) so it doesn't make sense to continue its support, so I'm dropping Chef 12 support starting from version 3.0.0 of this cookbook in favor of Chef 13.

## Attributes

Defaults that are used to configure nginx. If you want to change one of this parameters in nginx consider using provided LWRP and definitions.

* `node['nginx']['config']['conf_dir']` - Base nginx config directory. Default `/etc/nginx`.
* `node['nginx']['config']['log_dir']` - Directory for nginx log files. Default `/var/log/nginx`.
* `node['nginx']['config']['user']` - Default user that nginx will use to run worker processes. Default: `www-data`.
* `node['nginx']['config']['worker_processes']` - Number of nginx workers. Default `cpu['total']`.
* `node['nginx']['config']['worker_connections'] - Number of simultaneous connections that one worker can serve. Default `8192`.
* `node['nginx']['config']['worker_rlimit_nofile']` - Specifies the value for maximum file descriptors that can be opened by one worker process. Default `8192`.
* `node['nginx']['config']['pid']` - Path to Nginx pid file. Default: `/var/run/nginx.pid`
* `node['nginx']['config']['mainconfig_include']` - Include files into the main context of nginx.conf. Default: `nil`
* `node['nginx']['config']['error_log']` - Path to a default error log file. Default: `/var/log/nginx/error.log`


# Recipes

This cookbook provides only one recipe:

## default.rb

This default recipe will make some basic steps:

* installs Nginx from the package that is provided by your OS's package manager ("pin" the desired version using another cookbook);
* creates all directories for configuration, directory for log files, etc;
* creates default `nginx.conf` file and associated files;
* configures log rotation for Nginx;
* enables and starts Nginx service;
* runs resource that removes Nginx configuration files for sites, which are not defined by this cookbook's LWRP.

# Usage

## Wrapper-cookbook way

This cookbook has been designed to provide **LWRP** for your own infrastructure recipes. First of all, we should make our infrastructure cookbook to load this one.
* Do it by adding the line `depends nginx_lwrp` to your cookbook's metadata.rb.
* To make all default preparations for using Nginx invoke `include_recipe "nginx_lwrp"` inside your designated recipe.
* Now feel free to use all available LWRP provided by this cookbook.

## Roles-based way

Another way to use this cookbook is just to add `recipe[nginx_lwrp]` to your **run_list** before your recipe, which is resonsible for your infrastructure.

I personally prefer the first way because if you stick to it you'll eventually get complete and explicit "documentation" for your specific server installation. But in any case, you'll get Nginx installed, nginx.conf configured from the default template we provide, **LWRP** defined and ready to use.

## Official Nginx repo or default distro package

If you would like to use nginx package from official nginx repo, then just add `recipe[nginx_lwrp::official-repo]` or `include_recipe 'nginx_lwrp::official-repo'` before `nginx_lwrp` recipe invokation. Other wise default nginx package would be used from distro repository.

## LWRP

### nginx_site

This resource manages your Nginx sites configuraions.

#### Actions

<table>
  <thead>
    <tr>
      <th>Action</th>
      <th>Description</th>
      <th>Default</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>create</td>
      <td>
        Creates site configuration file inside "sites-available" directory, but doesn't enable it.
      </td>
      <td> </td>
    </tr>
    <tr>
      <td>enable</td>
      <td>
        Creates site configuration file inside "sites-available" directory, enables it (puts a symlink to it into "sites-enabled" directory)
      </td>
      <td>Yes</td>
    </tr>
    <tr>
     <td>disable</td>
      <td>
        Ensures that site configuration file is disabled.
      </td>
      <td> </td>
    </tr>
    <tr>
      <td>delete</td>
      <td>
        Disables and deletes site configuration file.
      </td>
      <td> </td>
    </tr>
  </tbody>
</table>

#### Attributes

<table>
  <thead>
    <tr>
      <th>Attribute</th>
      <th>Description</th>
      <th>Default Value</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>name</td>
      <td><b>Name attribute:</b> the name of the site's configuration file.</td>
      <td><code>nil</code></td>
    </tr>
    <tr>
      <td>template</td>
      <td>Defines what erb template file from the cookbook that invokes this resource we should use.</td>
      <td><code>name</code>.conf.erb</td>
    </tr>
    <tr>
      <td>variables</td>
      <td>Variables to be used in the template.</td>
      <td><code>Hash.new</code></td>
    </tr>
  </tbody>
</table>

#### Examples



```ruby
# We want to use "example.com.conf.erb" template file, do not want to pass any variables.
nginx_site 'example.com'

# Using custom-named template file and passing some variables, which can be used inside the template.
nginx_site 'forum.example.com' do
  action :enable
  template 'forum-nginx.erb'
  variables(
    listen_ip: '10.0.0.10',
    remote_ips: [ '10.0.0.2', '10.0.0.4' ]
  )
end

# Making sure that old site's configuration is disabled even if somebody has enabled it by hands.
nginx_site 'old.example.com' do
  action :disable
end
```

### nginx\_stream

Resource is completle similar to `nginx_site` except it is made to manage stream section includes.

#### Actions

<table>
  <thead>
    <tr>
      <th>Action</th>
      <th>Description</th>
      <th>Default</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>create</td>
      <td>
        Creates site configuration file inside "streams-available" directory, but doesn't enable it.
      </td>
      <td> </td>
    </tr>
    <tr>
      <td>enable</td>
      <td>
        Creates site configuration file inside "streams-available" directory, enables it (puts a symlink to it into "streams-enabled" directory)
      </td>
      <td>Yes</td>
    </tr>
    <tr>
     <td>disable</td>
      <td>
        Ensures that site configuration file is disabled.
      </td>
      <td> </td>
    </tr>
    <tr>
      <td>delete</td>
      <td>
        Disables and deletes site configuration file.
      </td>
      <td> </td>
    </tr>
  </tbody>
</table>

#### Attributes

<table>
  <thead>
    <tr>
      <th>Attribute</th>
      <th>Description</th>
      <th>Default Value</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>name</td>
      <td><b>Name attribute:</b> the name of the stream's configuration file.</td>
      <td><code>nil</code></td>
    </tr>
    <tr>
      <td>template</td>
      <td>Defines what erb template file from the cookbook that invokes this resource we should use.</td>
      <td><code>name</code>.conf.erb</td>
    </tr>
    <tr>
      <td>variables</td>
      <td>Variables to be used in the template.</td>
      <td><code>Hash.new</code></td>
    </tr>
  </tbody>
</table>

#### Examples

```ruby
# We want to use "example.com.conf.erb" template file, do not want to pass any variables.
nginx_stream 'stream-01'

# Using custom-named template file and passing some variables, which can be used inside the template.
nginx_stream 'tcp-stream' do
  action :enable
  template 'nginx-stream.erb'
  variables(
    listen_ip: '10.0.0.10',
    remote_ips: '10.0.0.2'
  )
end

# Making sure that old site's configuration is disabled even if somebody has enabled it by hands.
nginx_site 'old-stream' do
  action :disable
end
```

### nginx\_mainconfig

This resource is deprecated right now, use attributes instead.

```ruby
node.default['nginx']['config']['OPTION'] = 'VALUE'
```

#### List of allowed attributes

* [accept_mutex](http://nginx.org/en/docs/ngx_core_module.html#accept_mutex)
* [accept_mutex_delay](http://nginx.org/en/docs/ngx_core_module.html#accept_mutex_delay)
* [daemon](http://nginx.org/en/docs/ngx_core_module.html#daemon)
* [debug_points](http://nginx.org/en/docs/ngx_core_module.html#debug_points)
* [error_log](http://nginx.org/en/docs/ngx_core_module.html#error_log)
* [lock_file](http://nginx.org/en/docs/ngx_core_module.html#lock_file)
* [master_process](http://nginx.org/en/docs/ngx_core_module.html#master_process)
* [multi_accept](http://nginx.org/en/docs/ngx_core_module.html#multi_accept)
* [pcre_jit](http://nginx.org/en/docs/ngx_core_module.html#pcre_jit)
* [pid](http://nginx.org/en/docs/ngx_core_module.html#pid)
* [server_names_hash_bucket_size](http://nginx.org/en/docs/http/ngx_http_core_module.html#server_names_hash_bucket_size)
* [server_names_hash_max_size](http://nginx.org/en/docs/http/ngx_http_core_module.html#server_names_hash_max_size)
* [ssl_engine](http://nginx.org/en/docs/ngx_core_module.html#ssl_engine)
* [timer_resolution](http://nginx.org/en/docs/ngx_core_module.html#timer_resolution)
* [types_hash_bucket_size](http://nginx.org/en/docs/http/ngx_http_core_module.html#types_hash_bucket_size)
* [use](http://nginx.org/en/docs/ngx_core_module.html#use)
* [user](http://nginx.org/en/docs/ngx_core_module.html#user)
* [variables_hash_bucket_size](http://nginx.org/en/docs/http/ngx_http_core_module.html#variables_hash_bucket_size)
* [variables_hash_max_size](http://nginx.org/en/docs/http/ngx_http_core_module.html#variables_hash_max_size)
* [worker_connections](http://nginx.org/en/docs/ngx_core_module.html#worker_connections)
* [worker_aio_requests](http://nginx.org/en/docs/ngx_core_module.html#worker_aio_requests)
* [worker_cpu_affinity](http://nginx.org/en/docs/ngx_core_module.html#worker_cpu_affinity)
* [worker_priority](http://nginx.org/en/docs/ngx_core_module.html#worker_priority)
* [worker_processes](http://nginx.org/en/docs/ngx_core_module.html#worker_processes)
* [worker_rlimit_core](http://nginx.org/en/docs/ngx_core_module.html#worker_rlimit_core)
* [worker_rlimit_nofile](http://nginx.org/en/docs/ngx_core_module.html#worker_rlimit_nofile)
* [worker_rlimit_sigpending](http://nginx.org/en/docs/ngx_core_module.html#worker_rlimit_sigpending)
* [working_directory](http://nginx.org/en/docs/ngx_core_module.html#working_directory)

There are also attributes that can accept either a string or an array of strings:

* [env](http://nginx.org/en/docs/ngx_core_module.html#env)
* [load_module](http://nginx.org/en/docs/ngx_core_module.html#load_module)
* [debug_connection](http://nginx.org/en/docs/ngx_core_module.html#debug_connection)

## Small handy templates

As mentioned in the previous paragraph - main nginx config file acceps only limited set of options. But we always do some tuning like enabling compression, etc. I've created two small templates for a kind of configuration I usually use. It's a bit ugly and it's atemorary solution but may become usefull if you want some standart and clean confguration fast.

**Invoke each of these templates only once otherwise you'll have invalid nginx config.**

### gzip.conf.erb

Defaults to:
```
gzip on;
gzip_http_version 1.0;
gzip_comp_level 4;
gzip_proxied any;
gzip_types text/plain text/css application/x-javascript text/xml application/xml application/xml+rss text/javascript application/json;
gzip_disable msie6;
gzip_vary off;
```

How to use:

```ruby
# Use its default parameters.
nginx_site '00-gzip' do
  cookbook 'nginx_lwrp'
  template 'gzip.conf.erb'
end

# Or you can fine tune it.
nginx_site '01-gzip' do
  cookbook 'nginx_lwrp'
  template 'gzip.conf.erb'
  variables(
    enabled: true,
    http_version: '1.0',
    comp_version: 4,
    proxied: 'any',
    types: %w( text/plain text/css ),
    vary: 'off'
  )
end
```

### some-handy-defaults.conf.erb

Defaults to:

```
sendfile on;
tcp_nopush on;
tcp_nodelay on;
server_tokens off;
reset_timedout_connection off;

keepalive_timeout 65;
```

How to use:

```ruby
# Use its default parameters.
nginx_site '02-some-handy-defaults' do
  cookbook 'nginx_lwrp'
  template 'some-handy-defaults.conf.erb'
end

# Or you can fine tune it.
nginx_site '03-some-handy-defaults' do
  cookbook 'nginx_lwrp'
  template 'some-handy-defaults.conf.erb'
  variables(
    sendfile: 'on',
    tcp_nopush: 'on',
    tcp_nodelay: 'on',
    server_tokens: 'off',
    reset_timedout_connection: 'off',
    keepalive_timeout: 65
  )
end
```

### nginx\_logrotate

This resource and definition are deprecated right now. There are new attributes for log rotation configuration now: 

```ruby
node.default['nginx']['logrotate']['OPTION'] = 'VALUE'
```

Default logrotate configuration:

```
/var/log/nginx/*.log {
    daily
    missingok
    notifempty
    rotate 7
    compress
    create 640 root adm
    delaycompress
    sharedscripts
    postrotate
      test -f /var/run/nginx.pid && kill -USR1 "$(cat /var/run/nginx.pid)"
    endscript
}
```

#### Attributes

<table>
  <thead>
    <tr>
      <th>Attribute</th>
      <th>Description</th>
      <th>Default Value</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>logs</td>
      <td>Log files to be rotated. Wildcards are allowed.</td>
      <td>/var/log/nginx/*.log</td>
    </tr>
    <tr>
      <td>how_often</td>
      <td>Defines how often we should rotate logs. Allowed values are <i>daily</i>, <i>weekly</i>, <i>monthly</i>.</td>
      <td>daily</td>
    </tr>
    <tr>
      <td>copytruncate</td>
      <td>If true truncate the original log file to zero size in place after creating a copy, instead of moving the old log file and optionally creating a new one.</td>
      <td><code>false</code></td>
    </tr>
    <tr>
      <td>dateext</td>
      <td>If true archive  old  versions  of log files adding a daily extension like YYYYMMDD instead of simply adding a number. The extension may be configured using the dateformat option.</td>
      <td><code>false</code></td>
    </tr>
    <tr>
      <td>delaycompress</td>
      <td>If true postpone compression of the previous log file to the next rotation cycle.  This only has effect when used in combination  with  compress. It can be used when some program cannot be told to close its logfile and thus might continue writing to the previous log file for some time.</td>
      <td><code>true</code></td>
    </tr>
    <tr>
      <td>rotate</td>
      <td>Log files are rotated this number of times before being removed.</td>
      <td>7</td>
    </tr>
    <tr>
      <td>user</td>
      <td>Specifies the user name who will own the log file.</td>
      <td>root</td>
    </tr>
    <tr>
      <td>group</td>
      <td>Specifies the group the log file will belong to.</td>
      <td>adm</td>
    </tr>
    <tr>
      <td>mode</td>
      <td>Specifies the mode for the log file in octal.</td>
      <td>640</td>
    </tr>
    <tr>
      <td>pidfile</td>
      <td>Path to file that contains pid nuber of Nginx master process. If copytruncate is set to false we should send USR1 signal to that Nginx process to make it reopen log files after log rotation.</td>
      <td>/var/run/nginx.pid</td>
    </tr>
  </tbody>
</table>

### nginx\_disable\_cleanup

This resource is deprecated right now.

### nginx\_logrotate\_template

This resource is deprecated right now.

### nginx\_cleanup

This definitions is deprecated right now. Use attribute to disable cleanup:

```ruby
node.default['nginx']['enable_cleanup'] = false
```

## Sponsor

[![Sponsored by Evil Martians](https://evilmartians.com/badges/sponsored-by-evil-martians@2x.png)](https://evilmartians.com)

# License and Author

Kirill Kouznetsov (agon.smith@gmail.com)

Copyright (C) 2012-2018 Kirill Kouznetsov

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
