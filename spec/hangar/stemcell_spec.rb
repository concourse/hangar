require 'spec_helper'

require 'hangar/stemcell'

describe Hangar::Stemcell do
  let(:path) { 'stemcells/bosh-stemcell-2751.3-vsphere-esxi-ubuntu-trusty-go_agent.tgz' }

  subject(:stemcell) {
    Hangar::Stemcell.new(path)
  }

  it 'has a version' do
    expect(stemcell.version).to eq('2751.3')
  end

  it 'has a name' do
    expect(stemcell.name).to eq('bosh-vsphere-esxi-ubuntu-trusty-go_agent')
  end

  it 'has a file' do
    expect(stemcell.file).to eq('bosh-stemcell-2751.3-vsphere-esxi-ubuntu-trusty-go_agent.tgz')
  end
end
