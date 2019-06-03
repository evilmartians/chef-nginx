control 'nginx configuration tests' do
  title 'Checking nginx custom configuration'

  describe port('127.0.0.1', 80) do
    it { should be_listening }
  end

  describe file('/etc/nginx/mainconfig_custom_include.conf') do
    it { should be_file }
    it { should be_readable }
    it { should be_owned_by 'root' }
  end

  describe file('/etc/nginx/nginx.conf') do
    its('content') do
      should match(%r{^include /etc/nginx/mainconfig_custom_include\.conf;$})
    end
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

  describe http('http://localhost/nya', enable_remote_worker: true) do
    its('status') { should cmp 204 }
    its('headers.Neko') { should cmp 'nya' }
  end

  # Test for 'nginx_mainconfig'
  describe file('/etc/nginx/nginx.conf') do
    its('content') do
      should match(/^[ \t]*server_names_hash_bucket_size[ \t]+64;$/)
    end
  end

  describe file('/tmp/nginx_site_notification.txt') do
    it { should be_file }
    it { should be_readable }
    its('content') { should match(/passed/) }
  end

  # dhparam file generation
  describe file('/etc/nginx/dhparam.pem') do
    it { should be_readable }
    it { should be_owned_by 'root' }
  end
end
