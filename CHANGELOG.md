# nginx cookbook CHANGELOG

## 2.2.7 (2015-06-07)

* Bugfix: Making sure Nginx process is not stalled after initial installation.

## 2.2.6 (2015-06-07)

* Issue #10 fix.

## 2.2.5 (2015-06-07)

* Quotation marks around file modes in chef recipes.
* New default mime type: woff2.

## 2.2.4

* `recipe[nginx::official-repo]` that sets up official apt repository on Debian/Ubuntu.
* First cookbook dependency `cookbook[apt]`

## 2.2.3

* helper template with some handy default variables.
* nginx logrotate accepts more options to be configured: `dateext` and `delaycompress`
* gzip template default behaviour fix.