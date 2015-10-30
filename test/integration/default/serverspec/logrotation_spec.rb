require_relative '../../../kitchen/data/spec_helper'

describe 'Nginx logrotate configuration' do
  describe file('/etc/logrotate.d/nginx') do
    it { should be_file }
    it { should be_readable }
    it { should be_owned_by 'root' }
    its(:content) { should match(%r{/var/log/nginx/\*\.log}) }
    its(:content) { should match(/weekly/) }
    its(:content) { should match(/rotate 2/) }
    its(:content) { should match(/dateext/) }
    its(:content) { should match(/create 0644 root adm/) }
  end
end
