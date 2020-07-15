#
# Cookbook:: nomad
# Recipe:: manage
#
# Copyright:: 2015-2018, Nathan Williams <nath.e.will@gmail.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

systemd_unit 'nomad.service' do
  content <<~EOT.gsub('DAEMON_ARGS', node['nomad']['daemon_args'].to_args)
    [Unit]
    Description = Nomad Cluster Manager
    Documentation = https://www.nomadproject.io/docs/index.html

    [Service]
    ExecStart = /usr/local/sbin/nomad agent DAEMON_ARGS
    EnvironmentFile = -/etc/nomad.env
    Restart = on-failure

    [Install]
    WantedBy = multi-user.target
  EOT
  only_if { node['init_package'] == 'systemd' }
  notifies :restart, 'service[nomad]', :delayed
  action :create
end

service 'nomad' do
  action %i(enable start)
  subscribes :restart, 'nomad_config[00-default]', :delayed
  subscribes :restart, 'nomad_client_config[00-default]', :delayed
  subscribes :restart, 'nomad_server_config[00-default]', :delayed
  subscribes :restart, 'nomad_acl_config[00-default]', :delayed
end
