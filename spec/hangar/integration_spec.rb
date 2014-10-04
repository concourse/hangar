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

  describe 'building .pivotal files' do
    let(:stemcell_dir) { 'spec/assets/stemcell' }
    let(:release_dir) { 'spec/assets/release' }
    let(:product_name) { 'p-product' }

    before do
      FileUtils.rm_rf('p-product.pivotal')
    end

    it 'creates a p-concourse.pivotal file' do
      expect {
        hangar("--stemcell-dir #{stemcell_dir} --release-dir #{release_dir} --product-name #{product_name}")
      }.to change { File.exist? 'p-product.pivotal' }.from(false).to(true)
    end

    it 'creates a zip file with the correct stemcell' do
      hangar("--stemcell-dir #{stemcell_dir} --release-dir #{release_dir} --product-name #{product_name}")

      expect(files_in('p-product.pivotal')).to include('stemcells/stemcell.tgz')
    end

    it 'creates a zip file with the correct release' do
      hangar("--stemcell-dir #{stemcell_dir} --release-dir #{release_dir} --product-name #{product_name}")

      expect(files_in('p-product.pivotal')).to include('releases/release.tgz')
    end

    context 'with missing args' do
      it 'returns an error if no product name is given' do
        expect {
          hangar("--stemcell-dir #{stemcell_dir} --release-dir a/missing/dir")
        }.to raise_error /Please specify a product name \(--product-name\)/
      end
    end

    context 'with missing resources' do
      it 'returns an error if no stemcell could be found' do
        expect {
          hangar("--stemcell-dir a/missing/dir --release-dir #{release_dir} --product-name #{product_name}")
        }.to raise_error /Could not find a stemcell in directory: a\/missing\/dir/
      end

      it 'returns an error if no release could be found' do
        expect {
          hangar("--stemcell-dir #{stemcell_dir} --release-dir a/missing/dir --product-name #{product_name}")
        }.to raise_error /Could not find a release in directory: a\/missing\/dir/
      end
    end
  end
end