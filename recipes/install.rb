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

execute 'extract_openshift' do
  command "tar xa -f #{Chef::Config[:file_cache_path]}/openshift-origin.tar.gz --no-overwrite-dir -C /usr/local/bin" # rubocop:disable Metrics/LineLength
  action :nothing
end

remote_file "#{Chef::Config[:file_cache_path]}/openshift-origin.tar.gz" do
  source node['openshift'][node['openshift']['version']]['url']
  action :create
  notifies :run, 'execute[extract_openshift]', :immediately
end

# TODO: Add more platforms by adding the correct tests.
# TODO: Move init-system specific things into their own recipes

template '/etc/systemd/system/openshift.service' do
  cookbook 'openshift'
  action :create
  only_if do
    node['platform_family'] == 'rhel' && node['platform_version'].split('.')[0] == '7' # rubocop:disable Metrics/LineLength
  end
end

template '/etc/init/openshift.conf' do
  cookbook 'openshift'
  action :create
  only_if do
    node['platform'] == 'ubuntu' && node['platform_version'] == '14.04'
  end
end

service 'openshift' do
  action [:enable, :start]
end
