require 'spec_helper'

require 'yaml'

require 'hangar/metadata_template'
require 'hangar/release'

describe Hangar::MetadataTemplate do
  describe 'templating the metadata' do
    let(:result) { template.result(product_name, product_version, stemcell_version, releases) }
    let(:template) { Hangar::MetadataTemplate.from_file('spec/assets/metadata/metadata.yml.erb') }
    let(:output) { YAML.load(result) }

    let(:product_name) { 'p-product' }
    let(:product_version) { '1.0.0.0' }
    let(:stemcell_version) { '3263.17' }
    let(:releases) {
      [
          instance_double(
              Hangar::Release,
              name: "concourse",
              file: "concourse.tgz",
              version: "62.3",
          )
      ]
    }

    it 'templates the product name' do
      expect(output.fetch('name')).to eq(product_name)
    end

    it 'templates the product version' do
      expect(output.fetch('product_version')).to eq(product_version)
    end

    it 'templates the stemcell criteria version' do
      expect(output.fetch('stemcell_criteria').fetch('version')).to eq(stemcell_version)
    end

    it 'templates the releases' do
      expect(output.fetch('releases').first.fetch('name')).to eq(releases.first.name)
      expect(output.fetch('releases').first.fetch('version')).to eq(releases.first.version)
      expect(output.fetch('releases').first.fetch('file')).to eq(releases.first.file)
    end
  end
end
