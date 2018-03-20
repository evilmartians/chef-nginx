
control 'basic nginx tests' do
  title 'Check basic nginx installation'

  describe package('nginx') do
    it { should be_installed }
  end

  describe service('nginx') do
    it { should be_enabled }
    it { should be_running }
  end

  describe file('/etc/nginx/nginx.conf') do
    it { should be_file }
    it { should be_readable }
    it { should be_owned_by 'root' }

    its('content') { should match(/This file is generated and managed by/) }
    its('content') { should match(/'- \$connection/) }

    its('content') do
      should match(%r{^[ \t]*include[ \t]+/etc/nginx/mime.types;$})
    end
  end

  describe file('/etc/nginx/mime.types') do
    it { should be_file }
    it { should be_readable }
    it { should be_owned_by 'root' }
    its('content') { should match(/woff2/) }
  end

  describe command('/usr/sbin/nginx -tq') do
    its('exit_status') { should eq 0 }
  end
end
