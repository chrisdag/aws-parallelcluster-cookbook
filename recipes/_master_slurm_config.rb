# frozen_string_literal: true

#
# Cookbook Name:: aws-parallelcluster
# Recipe:: _master_slurm_config
#
# Copyright 2013-2015 Amazon.com, Inc. or its affiliates. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License"). You may not use this file except in compliance with the
# License. A copy of the License is located at
#
# http://aws.amazon.com/apache2.0/
#
# or in the "LICENSE.txt" file accompanying this file. This file is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES
# OR CONDITIONS OF ANY KIND, express or implied. See the License for the specific language governing permissions and
# limitations under the License.

# Export /opt/slurm
nfs_export "/opt/slurm" do
  network node['cfncluster']['ec2-metadata']['vpc-ipv4-cidr-blocks']
  writeable true
  options ['no_root_squash']
end

# Ensure config directory is in place
directory '/opt/slurm/etc' do
  user 'root'
  group 'root'
  mode '0755'
end

# Create directory configured as StateSaveLocation
directory '/var/spool/slurm.state' do
  user 'slurm'
  group 'slurm'
  mode '0700'
end

template '/opt/slurm/etc/slurm.conf' do
  source 'slurm.conf.erb'
  owner 'root'
  group 'root'
  mode '0644'
end

template '/opt/slurm/etc/slurm_parallelcluster_nodes.conf' do
  source 'slurm_parallelcluster_nodes.conf.erb'
  owner 'root'
  group 'root'
  mode '0644'
end

template '/opt/slurm/etc/gres.conf' do
  source 'gres.conf.erb'
  owner 'root'
  group 'root'
  mode '0644'
end

template '/opt/slurm/etc/slurm_parallelcluster_gres.conf' do
  source 'slurm_parallelcluster_gres.conf.erb'
  owner 'root'
  group 'root'
  mode '0644'
end

# alinux1 and centos6 use an old cgroup directory: /cgroup
# all other OSs use /sys/fs/cgroup, which is the default
template '/opt/slurm/etc/cgroup.conf' do
  source 'cgroup.conf.erb'
  owner 'root'
  group 'root'
  mode '0644'
end

cookbook_file '/opt/slurm/etc/slurm.sh' do
  source 'slurm.sh'
  owner 'root'
  group 'root'
  mode '0755'
end

cookbook_file '/opt/slurm/etc/slurm.csh' do
  source 'slurm.csh'
  owner 'root'
  group 'root'
  mode '0755'
end

cookbook_file '/etc/systemd/system/slurmctld.service' do
  source 'slurmctld.service'
  owner 'root'
  group 'root'
  mode '0644'
  action :create
  only_if { node['init_package'] == 'systemd' }
end

if node['init_package'] == 'systemd'
  service "slurmctld" do
    supports restart: false
    action %i[enable start]
  end
else
  service "slurm" do
    supports restart: false
    action %i[enable start]
  end
end
