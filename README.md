# Description

Installs Nginx from package, sets up some default configuration and defines LWRP supposed to be used inside your own cookbooks, which you use to manage your infrastructure.

# Sponsor

Sponsored by [Evil Martians](http://evilmartians.com)

# Requirements

## Cookbooks

At the moment this cookbook doesn't depend on other cookbooks but it will change in the future.

## Platform

The cookbook has been tested to work on `Debian 6`.

I suppose it should also work for last versions of Ubuntu and CenOS/RHEL but no tests have been conducted yet. I have some certain plans for porting and testing this cookbook on the above mentioned platforms after I finish its main funcionality.

## Chef version

Chef version >= `0.10.10` has to be used.

## Attributes

Tune the global nginx configuration via the following attributes:

* `node['nginx']['directories']['conf_dir']` - Path to the directory that contains Nginx configuration files.
* `node['nginx']['directories']['log_dir']` - Path to the directory where Nginx log file will be stored.
* `node['nginx']['user']` - User that Nginx will run as.
* `node['nginx']['gzip']['enable']` - Enables/disables gzip compression in Nginx.
* `node['nginx']['gzip']['gzip_http_version']` - Sets the minimum HTTP version of a request required to compress a response.
* `node['nginx']['gzip']['gzip_comp_level']` - Sets a gzip compression level of a response. Acceptable values are in the 1..9 range.
* `node['nginx']['gzip']['gzip_proxied']` - Enables or disables gzipping of responses for proxied requests depending on the request and response. See http://nginx.org/en/docs/http/ngx_http_gzip_module.html#gzip_proxied for more.
* `node['nginx']['gzip']['gzip_disable']` - Disables gzipping of responses for requests with 'User-Agent' header fields matching any of the specified regular expressions. The special mask 'msie6' (0.7.12) corresponds to the regular expression 'MSIE [4-6]\.' but works faster.
* `node['nginx']['gzip']['gzip_vary']` - Enables or disables emitting the 'Vary: Accept-Encoding' response header field if the directives gzip, gzip_static, or gunzip are active.
* `node['nginx']['gzip']['gzip_types']` - Enables gzipping of responses for the specified MIME types in addition to 'text/html'. The special value '*' matches any MIME type (0.8.29). Responses with the type 'text/html' are always compressed.
* `node['nginx']['reset_timedout_connection']` - Enables or disables resetting of timed out connections.
* `node['nginx']['keepalive']` - Enables or disables keep-alive client connections.
* `node['nginx']['keepalive_timeout']` - The first parameter sets a timeout during which a keep-alive client connection will stay open on the server side. The optional second parameter sets a value in the 'Keep-Alive: timeout=time' response header field. Two parameters may differ.
* `node['nginx']['worker_processes']` - Defines the number of worker processes for Nginx daemon.
* `node['nginx']['worker_connections']` - Sets the maximum number of simultaneous connections that can be opened by a worker process.
* `node['nginx']['server_names_hash_bucket_size']` - Sets the bucket size for the server names hash tables. See this http://nginx.org/en/docs/hash.html for details.
* `node['nginx']['worker_rlimit_nofile']` - Changes the limit on the maximum number of open files (RLIMIT_NOFILE) for worker processes. Used to increase the limit without restarting the main process.
* `node['nginx']['types_hash_bucket_size']` - Sets the bucket size for the types hash tables. See this http://nginx.org/en/docs/hash.html for datails.

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
* Do it by adding the line `depends nginx` to your cookbook's metadata.rb.
* To make all default preparations for using Nginx invoke `include_recipe "nginx"` inside your designated recipe.
* Now feel free to use all available LWRP provided by this cookbook.

## Roles-based way

Another way to use this cookbook is just to add `recipe[nginx]` to your **run_list** before your recipe, which is resonsible for your infrastructure.

I personally prefer the first way because if you stick to it you'll eventually get complete and explicit "documentation" for your specific server installation. But in any case, you'll get Nginx installed, nginx.conf configured from the default template we provide, **LWRP** defined and ready to use.

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
nginx_site "example.com"

# Using custom-named template file and passing some variables, which can be used inside the template.
nginx_site "forum.example.com" do
  action :enable
  template "forum-nginx.erb"
  variables(
    :listen_ip => "10.0.0.10",
    :remote_ips => [ "10.0.0.2", "10.0.0.4" ]
  )
end

# Making sure that old site's configuration is disabled even if somebody has enabled it by hands.
nginx_site "old.example.com" do
  action :disable
end
```

### nginx\_mainconfig

If you want to use a custom template for Nginx main configuration file, you can use this resource. It will search for the `:template` file in the "templates" directory of the cookbook that it is invoked from. In fact, you can invoke it as many times as you want, but only the last invokation will make changes to the system.
And the first place where it is invoked is default recipe of this cookbook.

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
      <td>Creates main Nginx configuration file <code>nginx.conf</code></td>
      <td>Yes</td>
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
      <td>template</td>
      <td><b>Name attribute:</b> erb template file, which will be used.
      </td>
      <td><code>nil</code></td>
    </tr>
    <tr>
      <td>variables</td>
      <td>
        Variables to be used in the template.
      </td>
      <td><code>Hash.new</code></td>
    </tr>
  </tbody>
</table>

#### Examples

```ruby
nginx_mainconfig "nginx-configuration.erb"

# or

nginx_mainconfig "nginx.conf.erb" do
  variables(
    :workers => 8,
    :rlimit  => 8192,
    :gzip    => true
  )
end
```

### nginx\_logrotate

This definition controls default log rotation settings for Nginx. Definition is used here as a wrapper because the name attibute can be omitted this way.
Log rotation is enabled by default and has following configuration:

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

#### Examples

```ruby
# Store rotated logs for 30 days and make them readable by everybody
nginx_logrotate do
  rotate 30
  mode 644
end

# Or full tuning
nginx_logrotate do
  logs ::File.join(node[:infrastucute_name][:logdir], "*.log")
  how_often "weekly"
  rotate 8
  copytruncate true
  user "root"
  group "adm"
  mode "660"
end
```

### nginx\_disable\_cleanup

This definition has no attributes or actions. Its invokation just disables the `nginx_cleanup` resource that is invoked by default.

### nginx\_logrotate\_template

The resource that is used by `nginx_logrotate` definition and default recipe of this cookbook and is not meant to be used inside your recipes.

### nginx\_cleanup

It finds all enabled Nginx site's configuration symlinks (or files if somebody was was too lazy or inattentive :) ) that aren't created using `nginx_site` and deletes them. If you do not want this to happen use `nginx_disable_cleanup` definition described above.

This resource is invoked from default recipe of this cookbook and is made to be invoked only once. 
