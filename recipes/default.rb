#
# Cookbook Name:: oc-limits
# Recipe:: default
#
# Author: Paul Mooring <paul@getchef.com>
# Copyright (c) 2014, Chef Software, Inc <legal@getchef.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

template '/etc/security/limits.conf' do
  source 'limits.conf.erb'
  variables(:limits => node['limits'].to_hash)
end

include_recipe 'runit'

bash 'restart runit' do
  user 'root'
  cwd '/tmp'
  code <<-EOH
    kill -HUP 1
    stop runsvdir
    sleep 2
    start runsvdir
  EOH
  action :nothing
end

template '/etc/init/runsvdir.conf' do
  source 'runsvdir.conf.erb'
  variables(:filtered_limits => LimitsHelpers.filter_limits(node['limits']['star'].to_hash))
  notifies :run, 'bash[restart runit]', :immediately
end
