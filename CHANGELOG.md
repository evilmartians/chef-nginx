# nginx cookbook CHANGELOG

## 2.2.4

* `recipe[nginx::official-repo]` that sets up official apt repository on Debian/Ubuntu.
* First cookbook dependency `cookbook[apt]`

## 2.2.3

* helper template with some handy default variables.
* nginx logrotate accepts more options to be configured: `dateext` and `delaycompress`
* gzip template default behaviour fix.