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

  def args(arg_hash)
    output = []

    arg_hash.each do |key, value|
      output << "--#{key} #{value}"
    end

    output.join(' ')
  end

  describe 'building .pivotal files' do
    let(:stemcell_dir) { 'spec/assets/stemcell' }
    let(:release_dir) { 'spec/assets/release' }
    let(:product_name) { 'p-product' }

    let(:valid_args) {
      {
          'product-name' => product_name,
          'stemcell-dir' => stemcell_dir,
          'release-dir' => release_dir,
      }
    }

    before do
      FileUtils.rm_rf('p-product.pivotal')
    end

    it 'creates a .pivotal file' do
      expect {
        hangar(args(valid_args))
      }.to change { File.exist? 'p-product.pivotal' }.from(false).to(true)
    end

    it 'creates a zip file with the correct stemcell' do
      hangar(args(valid_args))

      expect(files_in('p-product.pivotal')).to include('stemcells/stemcell.tgz')
    end

    it 'creates a zip file with the correct release' do
      hangar(args(valid_args))

      expect(files_in('p-product.pivotal')).to include('releases/release.tgz')
    end

    context 'with missing args' do
      it 'returns an error if no product name is given' do
        missing_product_name = valid_args.reject { |k,v| k == 'product-name' }

        expect {
          hangar(args(missing_product_name))
        }.to raise_error /Please specify a product name \(--product-name\)/
      end

      it 'returns an error if no stemcell directory is given' do
        missing_stemcell_dir = valid_args.reject { |k,v| k == 'stemcell-dir' }

        expect {
          hangar(args(missing_stemcell_dir))
        }.to raise_error /Please specify a stemcell directory \(--stemcell-dir\)/
      end

      it 'returns an error if no release directory is given' do
        missing_release_dir = valid_args.reject { |k,v| k == 'release-dir' }

        expect {
          hangar(args(missing_release_dir))
        }.to raise_error /Please specify a release directory \(--release-dir\)/
      end
    end

    context 'with missing resources' do
      it 'returns an error if no stemcell could be found' do
        bad_stemcell = valid_args.dup
        bad_stemcell.store('stemcell-dir', 'a/missing/dir')

        expect {
          hangar(args(bad_stemcell))
        }.to raise_error /Could not find a stemcell in directory: a\/missing\/dir/
      end

      it 'returns an error if no release could be found' do
        bad_release = valid_args.dup
        bad_release.store('release-dir', 'a/missing/dir')

        expect {
          hangar(args(bad_release))
        }.to raise_error /Could not find a release in directory: a\/missing\/dir/
      end
    end
  end
end