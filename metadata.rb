name              "nginx"
maintainer        "Kirill Kouznetsov"
maintainer_email  "agon.smith@gmail.com"
license           "Apache 2.0"
description       "Installs and configures nginx"
version           "2.1.0"

%w{ ubuntu debian }.each do |os|
  supports os
end

recipe "nginx", "Installs nginx package and sets up configuration similar to Debian's apachesites-enabled/sites-available"

attribute "nginx/directories/conf_dir",
  :display_name => "conf_dir",
  :description => "Path to Nginx config directory",
  :default => "/etc/nginx"

attribute "nginx/directories/log_dir",
  :display_name => "log_dir",
  :description => "Path to directory that contains log files",
  :default => "/var/log/nginx"

attribute "nginx/user",
  :display_name => "user",
  :description => "Defines user credentials used by worker processes",
  :default => "www-data"

attribute "nginx/gzip/enable",
  :display_name => "gzip_enable",
  :description => "Enables/disables gzip compression in nginx.",
  :default => "on"

attribute "nginx/gzip/gzip_http_version",
  :display_name => "gzip_http_version",
  :description => "Sets the minimum HTTP version of a request required to compress a response.",
  :default => "1.0"

attribute "nginx/gzip/gzip_comp_level",
  :display_name => "gzip_comp_level",
  :description => "Sets a gzip compression level of a response. Acceptable values are in the 1..9 range.",
  :default => "4"

attribute "nginx/gzip/gzip_proxied",
  :display_name => "gzip_proxied",
  :description => "Enables or disables gzipping of responses for proxied requests depending on the request and response. See http://nginx.org/en/docs/http/ngx_http_gzip_module.html#gzip_proxied for more.",
  :default => "any"

attribute "nginx/gzip/gzip_disable",
  :display_name => "gzip_disable",
  :description => "Disables gzipping of responses for requests with 'User-Agent' header fields matching any of the specified regular expressions. The special mask 'msie6' (0.7.12) corresponds to the regular expression 'MSIE [4-6]\.' but works faster.",
  :default => "msie6"

attribute "nginx/gzip/gzip_vary",
  :display_name => "gzip_vary",
  :description => "Enables or disables emitting the 'Vary: Accept-Encoding' response header field if the directives gzip, gzip_static, or gunzip are active.",
  :default => "off"

attribute "nginx/gzip/gzip_types",
  :display_name => "gzip_types",
  :description => "Enables gzipping of responses for the specified MIME types in addition to 'text/html'. The special value '*' matches any MIME type (0.8.29). Responses with the type 'text/html' are always compressed.",
  :default => [
    "text/plain",
    "text/css",
    "application/x-javascript",
    "text/xml",
    "application/xml",
    "application/xml+rss",
    "text/javascript",
    "application/json"
  ]

attribute "nginx/reset_timedout_connection",
  :display_name => "reset_timedout_connection",
  :description => "Enables or disables resetting of timed out connections.",
  :default => "off"

attribute "nginx/keepalive",
  :display_name => "keepalive",
  :description => "Enables keep-alive client connections",
  :default => "on"

attribute "nginx/keepalive_timeout",
  :display_name => "keepalive_timeout",
  :description => "The first parameter sets a timeout during which a keep-alive client connection will stay open on the server side. The optional second parameter sets a value in the 'Keep-Alive: timeout=time' response header field. Two parameters may differ.",
  :default => "65"

attribute "nginx/worker_processes",
  :display_name => "worker_processes",
  :description => "Defines the number of worker processes.",
  :default => "auto"

attribute "nginx/worker_connections",
  :display_name => "worker_connections",
  :description => "Sets the maximum number of simultaneous connections that can be opened by a worker process.",
  :default => "8192"

attribute "nginx/server_names_hash_bucket_size",
  :display_name => "server_names_hash_bucket_size",
  :description => "Sets the bucket size for the server names hash tables. See this http://nginx.org/en/docs/hash.html for details",
  :default => "64"

attribute "nginx/worker_rlimit_nofile",
  :display_name => "worker_rlimit_nofile",
  :description => "Changes the limit on the maximum number of open files (RLIMIT_NOFILE) for worker processes. Used to increase the limit without restarting the main process.",
  :default => "8192"

attribute "nginx/types_hash_bucket_size",
  :display_name => "types_hash_bucket_size",
  :description => "Sets the bucket size for the types hash tables. See this http://nginx.org/en/docs/hash.html for datails.",
  :default => "64"
