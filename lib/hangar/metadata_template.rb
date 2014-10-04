require 'erb'

module Hangar
  class MetadataTemplate
    def self.from_file(filename)
      new(File.read(filename))
    end

    def initialize(template)
      @template = ERB.new(template)
    end

    def result(product_name, product_version)
      template.result(binding)
    end

    private

    attr_reader :template
  end
end