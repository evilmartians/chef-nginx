require_relative '../../../kitchen/data/spec_helper'
require_relative '../../../kitchen/data/nginx_base_config_shared_tests'

describe 'Nginx installation' do
  include_examples 'Nginx base configuration'

  describe port(80) do
    it { should be_listening.on('127.0.0.1') }
  end

  describe file('/etc/nginx/mainconfig_custom_include.conf') do
    it { should be_file }
    it { should be_readable }
    it { should be_owned_by 'root' }
  end

  describe file('/etc/nginx/nginx.conf') do
    its(:content) { should match(%r{^include /etc/nginx/mainconfig_custom_include\.conf;$}) }
  end

  describe file('/etc/nginx/sites-available/frontend.conf') do
    it { should be_file }
    it { should be_readable }
    it { should be_owned_by 'root' }
  end

  describe file('/etc/nginx/sites-enabled/frontend.conf') do
    it { should be_symlink }
    it { should be_readable }
    it { should be_owned_by 'root' }
  end

  describe 'Nginx virtual host location /nya' do
    it 'Should return 204' do
      expect(get_http_response('http://localhost/nya').code.to_i).to eq(204)
    end
    it 'Should contain header "neko"' do
      expect(get_http_response('http://localhost/nya').to_hash.key?('neko')).to eq(true)
    end
  end

  # Test for 'nginx_mainconfig'
  describe file('/etc/nginx/nginx.conf') do
    its(:content) { should match(/^[ \t]*server_names_hash_bucket_size[ \t]+64;$/) }
    its(:content) { should_not match(/^[ \t]*stream {$/) }
  end
end

private

def get_http_response(address)
  uri = URI.parse(address)
  http = Net::HTTP.new(uri.host, uri.port)
  request = Net::HTTP::Get.new(uri.request_uri)

  http.request(request)
end
