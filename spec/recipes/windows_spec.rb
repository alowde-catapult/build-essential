require 'spec_helper'

describe 'build-essential::_windows' do
  let(:prefix) { 'C:\\mingw\\prefix' }
  let(:chef_run) do
    ChefSpec::ServerRunner.new(platform: 'windows', version: '2012R2') do |node|
      node.set['build-essential']['mingw']['prefix'] = prefix
    end.converge(described_recipe)
  end

  it 'creates the correct toolchain dir structure' do
    expect(chef_run).to create_directory('mingw root directory').with(path: prefix, recursive: true)
    expect(chef_run).to create_directory("#{prefix}/tool32")
    expect(chef_run).to create_directory("#{prefix}/tool64")
  end

  it 'removes legacy compiler toolchain' do
    allow(::File).to receive(:exist?).and_call_original
    allow(::File).to receive(:exist?).with(/msys/).and_return(true)
    expect(chef_run).to delete_directory(/Remove legacy compiler/).with(path: /msys/, recursive: true)
  end
end
