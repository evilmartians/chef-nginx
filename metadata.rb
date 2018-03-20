name              'nginx_lwrp'
maintainer        'Kirill Kouznetsov'
maintainer_email  'agon.smith@gmail.com'
license           'Apache-2.0'
description       'Installs and configures nginx'
version           '3.0.0'

depends 'apt'

supports 'ubuntu', '>= 14.04'
supports 'debian', '>= 8.0'

chef_version '>= 13.0', '< 14.0'

source_url 'https://github.com/evilmartians/chef-nginx'
issues_url 'https://github.com/evilmartians/chef-nginx/issues'
