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

node.default['seven_zip']['syspath'] = true
include_recipe 'seven_zip::default'

tool32_path = node['build-essential']['mingw32']['path'] if node['build-essential']['mingw32']
tool64_path = node['build-essential']['mingw64']['path'] if node['build-essential']['mingw64']
tool32_path = nil if tool32_path == ''
tool64_path = nil if tool64_path == ''

[tool32_path, tool64_path].compact.each do |tool_path|
  potentially_at_compile_time do
    directory tool_path do
      action :create
      recursive true
    end

    mingw_get "msys core in #{tool_path}" do
      package 'msys-base=2013072300-msys-bin.meta'
      root tool_path
    end

    mingw_get "msys core extensions in #{tool_path}" do
      package 'msys-coreutils-ext=5.97-3-*'
      root tool_path
    end

    mingw_get "msys perl in #{tool_path}" do
      package 'msys-perl-bin=5.8.8-*'
      root tool_path
    end

    mingw_get "msys patch in #{tool_path}" do
      package 'msys-patch-bin=2.6.1-*'
      root tool_path
    end

    mingw_get "bsdtar in #{tool_path}" do
      package 'mingw32-bsdtar-bin=2.8.3-*'
      root tool_path
    end

    remote_file "#{tool_path}\\bin\\tar.exe" do
      source "file:///#{tool_path.tr('\\', '/')}/bin/bsdtar.exe"
    end
  end
end

if tool32_path
  potentially_at_compile_time do
    mingw_tdm_gcc 'TDM GCC 32-bit with SJLJ' do
      version '5.1.0'
      flavor :sjlj_32
      root tool32_path
    end
  end
end

if tool64_path
  potentially_at_compile_time do
    mingw_tdm_gcc 'TDM GCC 64-bit with SJLJ/SEH' do
      version '5.1.0'
      flavor :seh_sjlj_64
      root tool64_path
    end
  end
end
