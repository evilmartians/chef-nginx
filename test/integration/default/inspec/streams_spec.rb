control 'nginx streams configuration' do
  title 'Check custom configuration for Nginx streams.'

  %w[sites streams].each do |section|
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
      its('content') { should match(/Here you are a cat/) }
    end
  end

  # Test for 'nginx_mainconfig'
  describe file('/etc/nginx/nginx.conf') do
    its('content') { should match(/^[ \t]*stream {$/) }
  end
end
