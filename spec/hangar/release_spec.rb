require 'spec_helper'

require 'hangar/release'

describe Hangar::Release do
  let(:path) { 'spec/assets/release/release-name.tgz' }

  subject(:release) {
    Hangar::Release.new(path)
  }

  it 'has a version' do
    expect(release.version).to eq('0.43.0')
  end

  it 'has a name' do
    expect(release.name).to eq('concourse')
  end

  it 'has a file' do
    expect(release.file).to eq('release-name.tgz')
  end
end
