source 'https://supermarket.chef.io'

cookbook 'mingw', git: 'https://github.com/chef-cookbooks/mingw.git'

metadata

group :integration do
  cookbook 'yum'
  cookbook 'apt'
  cookbook 'freebsd'
end
