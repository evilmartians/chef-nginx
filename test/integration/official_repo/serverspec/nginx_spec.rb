require_relative '../../../kitchen/data/spec_helper'
require_relative '../../../kitchen/data/nginx_base_config_shared_tests'

describe 'Nginx installation w/ official Nginx repo' do
  describe file('/etc/apt/sources.list.d/nginx.list') do
    it { should be_file }
    it { should be_readable }
    it { should be_owned_by 'root' }
    its(:content) { should match(%r{deb[ \t]+http://nginx.org/packages/mainline/#{os[:family]}/[ \t]+#{os_codename}[ \t]+nginx}) }
  end

  include_examples 'Nginx base configuration'
end

private

def os_codename
  `/usr/bin/lsb_release -c`.split.last
end
