name              'nginx'
maintainer        'Kirill Kouznetsov'
maintainer_email  'agon.smith@gmail.com'
license           'Apache 2.0'
description       'Installs and configures nginx'
version           '2.3.2'

%w( ubuntu debian ).each do |os|
  supports os
end

depends 'apt'

recipe 'nginx', "Installs nginx package and sets up configuration similar to Debian's apachesites-enabled/sites-available"
recipe 'nginx::official-repo', 'Sets up official apt repository on Debian/Ubuntu.'
