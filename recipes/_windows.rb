#
# Cookbook Name:: build-essential
# Recipe:: _windows
#
# Copyright 2016, Chef Software, Inc.
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
#

include_recipe 'seven_zip::default'

# The general layout is as such:
# + mingw-prefix
# |-  base   - holds common 32 and 64-bit msys packages.  Files from here are
# |            copied into locations below.
# |+  tool32 - 32-bit toolchain.
#  |- .cache - holds temporary tar files and fetches/extracted packages.
# |+  tool64 - 64-bit toolchain.
#  |- .cache - holds temporary tar files and fetches/extracted packages.
#
# TODO: See if one can use /etc/fstab in base to mount tool32/tool64 as needed
# instead of copying all the time.

prefix = node['build-essential']['mingw']['prefix']
base_path = ::File.join(prefix, 'base')
tool32_path = ::File.join(prefix, 'tool32')
tool64_path = ::File.join(prefix, 'tool64')

potentially_at_compile_time do
  directory 'mingw root directory' do
    path prefix
    action :create
    recursive true
  end

  mingw_get 'msys core' do
    package 'msys-base=2013072300-msys-bin.meta'
    root base_path
  end

  mingw_get 'msys core extensions' do
    package 'msys-core-utils-ext=5.97-3-*'
    root base_path
  end

  mingw_get 'msys perl' do
    package 'msys-perl-bin=5.8.8-*'
    root base_path
  end

  directory tool32_path do
  end

  directory tool64_path do
  end

  ruby_block 'copy base files into tool32 and tool64' do
    block do
      ::FileUtils.cp_r("#{base_path}/.", tool32_path)
      ::FileUtils.cp_r("#{base_path}/.", tool64_path)
    end
  end

  mingw_tdm_gcc 'TDM GCC 32-bit with SJLJ' do
    version '5.1.0'
    flavor :sjlj_32
    root tool32_path
  end

  mingw_tdm_gcc 'TDM GCC 64-bit with SJLJ/SEH' do
    version '5.1.0'
    flavor :seh_sjlj_64
    root tool64_path
  end
end

# Clear out legacy compiler installation if present.
# TODO: Remove this once all jenkins nodes have been converged with new changes
# at least once.
potentially_at_compile_time do
  legacy_path = node['build-essential']['msys']['path'] if node['build-essential']['msys']
  unless legacy_path.nil?
    Chef::Log.warn(
      'node[build-essential][msys][path] is deprecated - use node[build-essential][mingw][prefix] instead')
  end
  legacy_path ||= "#{ENV['SYSTEMDRIVE']}\\msys"

  directory "Remove legacy compiler toolchain at #{legacy_path}" do
    path legacy_path
    action :delete
    recursive true
    only_if { ::File.exist?(legacy_path) }
  end
end
