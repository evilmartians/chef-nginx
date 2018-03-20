control 'nginx package repo' do
  title 'Checking that nginx is installed from the official repo'

  os_codename = command('/usr/bin/lsb_release -cs').stdout.strip.downcase
  repo_url = "http://nginx.org/packages/mainline/#{os[:name]}/"

  describe file('/etc/apt/sources.list.d/nginx.list') do
    it { should be_file }
    it { should be_readable }
    it { should be_owned_by 'root' }

    its('content') do
      should match(/deb[ \t]+"#{repo_url}"[ \t]+#{os_codename}[ \t]+nginx/)
    end
  end
end
