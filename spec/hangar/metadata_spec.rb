require 'spec_helper'

require 'yaml'

require 'hangar/metadata_template'

describe Hangar::MetadataTemplate do
  describe 'templating the metadata' do
    let(:template) { Hangar::MetadataTemplate.from_file('spec/assets/metadata/metadata.yml.erb') }
    let(:result) { template.result(product_name, product_version, stemcell, releases) }
    let(:output) { YAML.load(result) }

    let(:product_name) { 'p-product' }
    let(:product_version) { '1.0.0.0' }
    let(:stemcell) {
      instance_double(
          Hangar::Stemcell,
          name: 'bosh-vsphere-esxi-ubuntu-trusty-go_agent',
          version: '2690.3',
          file: 'bosh-stemcell-2690.3-vsphere-esxi-ubuntu-trusty-go_agent.tgz',
      )
    }
    let(:releases) {
      [
          instance_double(
              Hangar::Release,
              name: "release-name",
              file: "release-name-62.3.tgz",
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

    it 'templates in the stemcell' do
      expect(output.fetch('stemcell').fetch('name')).to eq(stemcell.name)
      expect(output.fetch('stemcell').fetch('version')).to eq(stemcell.version)
      expect(output.fetch('stemcell').fetch('file')).to eq(stemcell.file)
    end

    it 'templates the releases' do
      expect(output.fetch('releases').first.fetch('name')).to eq(releases.first.name)
      expect(output.fetch('releases').first.fetch('version')).to eq(releases.first.version)
      expect(output.fetch('releases').first.fetch('file')).to eq(releases.first.file)
    end
  end
end
