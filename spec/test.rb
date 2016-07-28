#describe port(67) do
#  it { should be_listening }
#end

# Services running
describe port(69) do
  it { should be_listening }
end
describe port(80) do
  it { should be_listening }
end

# Packages installed
pkgs = %w(
  apache2
  wget
  ca-certificates
  net-tools
)
pkgs.each do |pkg|
  describe package(pkg) do
    it { should be_installed }
  end
end

# Files in the right spot
describe file("/var/www/html") do
  it { should be_directory }
end
describe file("/nbi") do
  it { should be_directory }
end
describe file("/nbi/mactel64.efi") do
  it { should be_file }
end
describe file("/nbi/boot/grub/i386-pc/core.0") do
  it { should be_file }
end
describe file("/etc/dhcp/dhcpd.conf") do
  it { should be_file }
  its('content') { should match /mactel64.efi/ }
  its('content') { should match /core.0/ }
end
describe file("/var/www/html/ks.php") do
  it { should be_file }
  its('content') { should match /cfg/ }
end
describe file("/var/www/html/cfg") do
  it { should be_directory }
end
describe file("/var/www/html/repos") do
  it { should be_directory }
end
describe file("/root/cron.sh") do
  it { should be_file }
  its('content') { should match /cron/ }
end
