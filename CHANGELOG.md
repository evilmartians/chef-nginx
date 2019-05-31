# nginx_lwrp cookbook CHANGELOG

## 3.0.3 (2019-05-31)

* Chef 15 support;
* Ubuntu 18.04 support;
* Test Kitchen: tests with Chef 15;

## 3.0.2 (2018-04-04)

* Chef 14 support;
* Test Kitchen: main tests are switched to Chef 14;
* Test Kitchen: smoke test for Chef 13 was added;
* Test Kitchen: second config file to run tests in Docker using TravisCI itself;
* TravisCI integration & auto-deploy;

## 3.0.1 (2018-03-26)

* TESTING.md file added to comply with supermarket validations.
* Foodcritic FC117 & FC118 fixes.

## 3.0.0 (2018-03-20)

* [Breaking change] **Chef 12 is not supported anymore**, see below for comments.
* [Breaking change] no more `nginx_disable_cleanup` definition
* [Breaking change] no more `nginx_logrotate` definition
* Chef 13 support
* cookbook name was changed to `nginx_lwrp` to add this cookbook to Supermarket.
* new list of supported OSes:
  * Ubuntu 14.04
  * Ubuntu 16.04
  * Debian 8
  * Debian 9
* LWRPs were rewritten using [new style](https://docs.chef.io/custom_resources.html)
* Inspec is used instead of ServerSpec now
* Gemfile update
* Rubocop offences were fixed
* Foodcritic offences were fixed

Please be warned!!! Сhef 12 is reaching its EOL in April 2018 and will be removed from [downloads.chef.io](https://downloads.chef.io) so it doesn't make sense to continue its support, so I'm dropping Chef 12 support starting from version 3.0.0 of this cookbook in favor of Chef 13 support. 

## 2.3.5 (2017-03-24)

* nginx.conf template should accept `load_module` option.

## 2.3.4 (2016-11-02)

* DH param file was renames to the expected one.

## 2.3.3 (2016-10-04)

* Descent DH params file is generated after nginx package installation.

## 2.3.2 (2016-)

* Test Kitchen: Debian 7 was added to the test suite.
* `mainconfig_include_file` option was added.
* Now using correct dummy template for config file for custom includes to main nginx config.

## 2.3.1 (2016-02-03)

* Returned some back compatibility with Chef 11. As it was broken by me in previous release.

## 2.3.0 (2015-11-03)

* New resource `nginx_streams`. Which uses the same provider as `nginx_sites` but manages `streams-available` & `streams-enabled` directories.
* Provider `Chef::Provider::NginxSites` refactored to support logic for previously mentioned change.

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
