require 'spec_helper'

require 'hangar/release'

describe Hangar::Release do
  let(:path) { 'releases/amazing-concourse-5.3.4.tgz' }
  
  subject(:release) {
    Hangar::Release.new(path)
  }
  
  it 'has a version' do
    expect(release.version).to eq('5.3.4')
  end
  
  it 'has a name' do
    expect(release.name).to eq('amazing-concourse')
  end
  
  it 'has a file' do
    expect(release.file).to eq('amazing-concourse-5.3.4.tgz')
  end
end