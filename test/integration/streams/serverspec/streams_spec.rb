require_relative '../../../kitchen/data/spec_helper'
require_relative '../../../kitchen/data/nginx_base_config_shared_tests'

describe 'Steams Nginx configuration installation' do
  %w(sites streams).each do |section|
    describe file("/etc/nginx/#{section}-available/test01.conf") do
      it { should be_file }
      it { should be_readable }
      it { should be_owned_by 'root' }
    end

    describe file("/etc/nginx/#{section}-enabled/test01.conf") do
      it { should be_symlink }
      it { should be_readable }
      it { should be_owned_by 'root' }
    end

    describe file("/etc/nginx/#{section}-available/test01.conf") do
      its(:content) { should match(/Here you are a cat/) }
    end
  end

  # Test for 'nginx_mainconfig'
  describe file('/etc/nginx/nginx.conf') do
    its(:content) { should match(/^[ \t]*stream {$/) }
  end
end
