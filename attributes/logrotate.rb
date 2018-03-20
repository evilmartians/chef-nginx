default['nginx']['logrotate']['logs'] = ::File.join(
  node['nginx']['config']['log_dir'],
  '*.log',
)
default['nginx']['logrotate']['how_often'] = 'daily'
default['nginx']['logrotate']['rotate'] = '7'
default['nginx']['logrotate']['copytruncate'] = false
default['nginx']['logrotate']['user'] = 'root'
default['nginx']['logrotate']['group'] = 'adm'
default['nginx']['logrotate']['mode'] = '0640'
default['nginx']['logrotate']['pidfile'] = node['nginx']['config']['pid']
default['nginx']['logrotate']['dateext'] = false
default['nginx']['logrotate']['delaycompress'] = true
