require 'erb'
require 'ostruct'

module Hangar
  class MetadataTemplate
    def self.from_file(filename)
      new(File.read(filename))
    end

    def initialize(template)
      @template = ERB.new(template)
    end

    def result(product_name, product_version, stemcell, releases)
      context = Context.new(product_name, product_version, stemcell, releases)
      template.result(context.get_binding)
    end

    private

    attr_reader :template

    class Context
      def initialize(product_name, product_version, stemcell, releases)
        @product_name = product_name
        @product_version = product_version
        @stemcell = stemcell
        @releases = releases
      end

      def get_binding
        binding
      end

      def product_name
        wrap(@product_name)
      end

      def product_version
        wrap(@product_version)
      end

      def stemcell
        OpenStruct.new(
            name: wrap(@stemcell.name),
            file: wrap(@stemcell.file),
            version: wrap(@stemcell.version),
        )
      end
      
      def releases
        releases = {}
        
        @releases.each do |release|
          releases[release.name] = OpenStruct.new(
            name: wrap(release.name),
            file: wrap(release.file),
            version: wrap(release.version),
          )
        end
        
        releases
      end

      private

      def wrap(value)
        "'#{value}'"
      end
    end
  end
end