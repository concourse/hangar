require 'spec_helper'

require 'yaml'

require 'hangar/metadata_template'

describe Hangar::MetadataTemplate do
  describe 'templating the metadata' do
    let(:template) { Hangar::MetadataTemplate.from_file('spec/assets/metadata/metadata.yml.erb') }
    let(:result) { template.result(product_name, product_version, stemcell) }
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
  end
end