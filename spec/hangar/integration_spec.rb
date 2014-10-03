require 'spec_helper'

require 'fileutils'
require 'zip'

require 'hangar/cli'

describe 'Hangar' do
  def hangar(args)
    Hangar::Cli.new(args.split(' ')).run!
  end

  def files_in(zip)
    entries = []

    Zip::File.foreach(zip) do |entry|
      entries << entry.name
    end

    entries
  end
  
  let(:stemcell_dir) { 'spec/assets/stemcell' }
  let(:release_dir) { 'spec/assets/release' }
  
  before do
    FileUtils.rm_rf('p-concourse.pivotal')
  end
  
  it 'creates a p-concourse.pivotal file' do
    expect {
      hangar("--stemcell-dir #{stemcell_dir} --release-dir #{release_dir}")
    }.to change { File.exist? 'p-concourse.pivotal' }.from(false).to(true)
  end
  
  it 'creates a zip file with the correct stemcell' do
    hangar("--stemcell-dir #{stemcell_dir} --release-dir #{release_dir}")

    expect(files_in('p-concourse.pivotal')).to include('stemcells/stemcell.tgz')
  end

  it 'creates a zip file with the correct release' do
    hangar("--stemcell-dir #{stemcell_dir} --release-dir #{release_dir}")

    expect(files_in('p-concourse.pivotal')).to include('releases/release.tgz')
  end

  context 'with missing resources' do
    it 'returns an error if no stemcell could be found' do

    end

    it 'returns an error if no release could be found' do

    end
  end
end