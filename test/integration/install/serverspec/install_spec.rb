#   Copyright 2015 Lyle Dietz
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.

require 'serverspec'

set :backend, :exec

describe 'openshift::install' do
  it 'downloaded archive to filesystem' do
    expect(file('/tmp/kitchen/cache/openshift-origin.tar.gz')).to be_file
  end

  %w(oadm openshift oc).each do |cmd|
    it "extracted #{cmd}" do
      expect(file("/usr/local/bin/#{cmd}")).to be_file
      expect(file("/usr/local/bin/#{cmd}")).to be_executable
    end
  end

  it "didn't change the mode of /usr/local/bin" do
    expect(file('/usr/local/bin')).to be_readable.by 'others'
    expect(file('/usr/local/bin')).to be_executable.by 'others'
  end

  describe 'systemd set up', if: os[:family] == 'redhat' do
    it 'created the unit file' do
      expect(file('/etc/systemd/system/openshift.service')).to be_file
    end
  end

  describe 'upstart set up', if: os[:family] == 'ubuntu' do
    it 'created the upstart job' do
      expect(file('/etc/init/openshift.conf')).to be_file
    end
  end

  it 'enabled openshift' do
    expect(service('openshift')).to be_enabled
  end

  it 'started openshift' do
    expect(service('openshift')).to be_running
  end
end
