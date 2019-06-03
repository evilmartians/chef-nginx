control 'basic nginx tests' do
  title 'Check basic nginx installation'

  describe package('nginx') do
    it { should be_installed }
  end

  # Chef 14 resource service is broken on a first run on Ubuntu 14.
  if os.name == 'ubuntu' and os.release.to_f > 14.04
    describe service('nginx') do
      it { should be_enabled }
      it { should be_running }
    end
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
