require 'spec_helper'

require 'fileutils'
require 'yaml'
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

  def extract_contents_from(zip, filename)
    Zip::File.open(zip) do |zip_file|
      entry = zip_file.glob(filename).first
      entry.get_input_stream.read
    end
  end

  def args(arg_hash)
    output = []

    arg_hash.each do |key, values|
      values.each do |value|
        output << "--#{key} #{value}"
      end
    end

    output.join(' ')
  end

  describe 'building a .pivotal file' do
    let(:release_dir) { 'spec/assets/release' }
    let(:other_release_dir) { 'spec/assets/other-release' }
    let(:product_name) { 'p-product' }
    let(:metadata_template_path) { 'spec/assets/metadata/metadata.yml.erb' }
    let(:product_version) { '0.3' }

    let(:output_file) { 'p-product-0.3.pivotal' }

    let(:valid_args) {
      {
          'product-name' => [product_name],
          'release-dir' => [release_dir, other_release_dir],
          'metadata-template' => [metadata_template_path],
          'product-version' => [product_version]
      }
    }

    before do
      FileUtils.rm_rf(output_file)
    end

    it 'creates a .pivotal file' do
      expect {
        hangar(args(valid_args))
      }.to change { File.exist? output_file }.from(false).to(true)
    end

    it 'contains the both correct releases' do
      hangar(args(valid_args))

      expect(files_in(output_file)).to include('releases/release-name.tgz')
      expect(files_in(output_file)).to include('releases/second-release-name.tgz')
      expect(files_in(output_file)).to include('releases/other-release.tgz')
    end

    it 'contains valid YAML metadata' do
      hangar(args(valid_args))

      expect(files_in(output_file)).to include('metadata/metadata.yml')

      metadata_contents = extract_contents_from(output_file, 'metadata/metadata.yml')
      product_metadata = YAML.load(metadata_contents)

      expect(product_metadata.fetch('releases').first.fetch('name')).to eq('concourse')
      expect(product_metadata.fetch('releases').first.fetch('version')).to eq('0.43.0')
    end

    context 'with missing arguments' do
      it 'returns an error if no product name is given' do
        missing_product_name = valid_args.reject { |k,v| k == 'product-name' }

        expect {
          hangar(args(missing_product_name))
        }.to raise_error /Please specify a product name \(--product-name\)/
      end

      it 'returns an error if no product version is given' do
        missing_product_version = valid_args.reject { |k,v| k == 'product-version' }

        expect {
          hangar(args(missing_product_version))
        }.to raise_error /Please specify a product version \(--product-version\)/
      end

      it 'returns an error if no metadata template is given' do
        missing_template_path = valid_args.reject { |k,v| k == 'metadata-template' }

        expect {
          hangar(args(missing_template_path))
        }.to raise_error /Please specify a metadata template \(--metadata-template\)/
      end

      it 'returns an error if no release directory is given' do
        missing_release_dir = valid_args.reject { |k,v| k == 'release-dir' }

        expect {
          hangar(args(missing_release_dir))
        }.to raise_error /Please specify a release directory \(--release-dir\)/
      end
    end

    context 'with missing resources' do
      it 'returns an error if no metadata could be found' do
        bad_metadata = valid_args.dup
        bad_metadata.store('metadata-template', ['a/missing/file.yml.erb'])

        expect {
          hangar(args(bad_metadata))
        }.to raise_error /Could not find a metadata template: a\/missing\/file.yml.erb/
      end

      it 'returns an error if no release could be found' do
        bad_release = valid_args.dup
        bad_release.store('release-dir', ['a/missing/dir'])

        expect {
          hangar(args(bad_release))
        }.to raise_error /Could not find a release in directory: a\/missing\/dir/
      end
    end
  end
end
