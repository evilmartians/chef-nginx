name              "nginx"
maintainer        "Kirill Kouznetsov"
maintainer_email  "agon.smith@gmail.com"
license           "Apache 2.0"
description       "Installs and configures nginx"
version           "2.2.0"

%w{ ubuntu debian }.each do |os|
  supports os
end

recipe "nginx", "Installs nginx package and sets up configuration similar to Debian's apachesites-enabled/sites-available"

