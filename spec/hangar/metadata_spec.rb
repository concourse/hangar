require 'spec_helper'

require 'yaml'

require 'hangar/metadata_template'

describe Hangar::MetadataTemplate do
  describe 'templating the metadata' do
    let(:template) { Hangar::MetadataTemplate.from_file('spec/assets/metadata/metadata.yml.erb') }
    let(:result) { template.result(product_name, product_version) }
    let(:output) { YAML.load(result) }

    let(:product_name) { 'p-product' }
    let(:product_version) { '1.0.0.0' }

    it 'templates the product name' do
      expect(output.fetch('name')).to eq(product_name)
    end

    it 'templates the product version' do
      expect(output.fetch('product_version')).to eq(product_version)
    end
  end
end