require_relative '../../../kitchen/data/spec_helper'

describe 'Check helper template logic' do
  describe file('/etc/nginx/sites-available/00-gzip-defaults.conf') do
    it { should be_file }
    it { should be_readable }
    it { should be_owned_by 'root' }
    its(:content) { should match(/gzip on;/) }
    its(:content) { should match(/gzip_http_version 1.0;/) }
    its(:content) { should match(/gzip_comp_level 4;/) }
    its(:content) { should match(/gzip_proxied any;/) }
    its(:content) { should match(%r{gzip_types text/plain text/css}) }
    its(:content) { should match(/gzip_disable msie6;/) }
    its(:content) { should match(/gzip_vary off;/) }
  end

  describe file('/tmp/01-some-handy-defaults') do
    it { should be_file }
    it { should be_readable }
    it { should be_owned_by 'root' }
    its(:content) { should match(/This file is managed by Chef/) }
    its(:content) { should match(/sendfile off;/) }
    its(:content) { should match(/tcp_nopush on;/) }
    its(:content) { should match(/tcp_nodelay on;/) }
    its(:content) { should match(/server_tokens off;/) }
    its(:content) { should match(/reset_timedout_connection off;/) }
    its(:content) { should_not match(/keepalive_timeout/) }
  end

  describe file('/tmp/02-some-handy-defaults') do
    it { should be_file }
    it { should be_readable }
    it { should be_owned_by 'root' }
    its(:content) { should match(/This file is managed by Chef/) }
    its(:content) { should match(/sendfile on;/) }
    its(:content) { should match(/tcp_nopush on;/) }
    its(:content) { should match(/tcp_nodelay on;/) }
    its(:content) { should match(/server_tokens on;/) }
    its(:content) { should match(/reset_timedout_connection on;/) }
    its(:content) { should match(/keepalive_timeout 65;/) }
  end

  describe file('/tmp/03-some-handy-defaults') do
    it { should be_file }
    it { should be_readable }
    it { should be_owned_by 'root' }
    its(:content) { should match(/This file is managed by Chef/) }
    its(:content) { should match(/sendfile on;/) }
    its(:content) { should match(/tcp_nopush on;/) }
    its(:content) { should match(/tcp_nodelay on;/) }
    its(:content) { should match(/server_tokens off;/) }
    its(:content) { should match(/reset_timedout_connection off;/) }
    its(:content) { should match(/keepalive_timeout 65;/) }
  end
end
