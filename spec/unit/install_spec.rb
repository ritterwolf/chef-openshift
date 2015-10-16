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

require 'spec_helper'

# rubocop:disable Metrics/LineLength

archive_file = 'openshift-origin.tar.gz'

describe 'Common openshift::install' do
  let(:chef_run) { ChefSpec::ServerRunner.converge('openshift::install') }
  let(:archive_remote_file) { chef_run.remote_file("#{Chef::Config[:file_cache_path]}/#{archive_file}") }
  let(:archive_extraction) { chef_run.execute('extract_openshift') }

  it 'downloads the binaries' do
    expect(chef_run).to create_remote_file("#{Chef::Config[:file_cache_path]}/#{archive_file}")
  end

  it 'extracts the binaries' do
    expect(archive_extraction).to do_nothing
    expect(archive_remote_file).to notify('execute[extract_openshift]').to(:run).immediately
  end
end

describe 'Centos openshift::install' do
  let(:chef_run) { ChefSpec::ServerRunner.new(platform: 'centos', platform_family: 'rhel', version: '7.0').converge('openshift::install') }

  it 'configures systemd' do
    expect(chef_run).to render_file '/etc/systemd/system/openshift.service'
  end

  it 'enables the openshift service' do
    expect(chef_run).to enable_service 'openshift'
  end

  it 'starts the openshift service' do
    expect(chef_run).to start_service 'openshift'
  end
end

describe 'Ubuntu openshift::install' do
  let(:chef_run) { ChefSpec::ServerRunner.new(platform: 'ubuntu', version: '14.04').converge('openshift::install') }

  it 'configures upstart' do
    expect(chef_run).to render_file '/etc/init/openshift.conf'
  end

  it 'enables the openshift service' do
    expect(chef_run).to enable_service 'openshift'
  end

  it 'starts the openshift service' do
    expect(chef_run).to start_service 'openshift'
  end
end
