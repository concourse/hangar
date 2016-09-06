require 'erb'
require 'ostruct'

module Hangar
  class ContentMigrations
    def self.from_file(filename)
      new(File.read(filename))
    end

    def initialize(template)
      @template = ERB.new(template)
    end

    def result(product_name, product_version)
      context = Context.new(product_name, product_version)
      template.result(context.get_binding)
    end

    private

    attr_reader :template

    class Context
    def initialize(product_name, product_version)
      @product_name = product_name
      @product_version = product_version
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

    def wrap(value)
      "'#{value}'"
    end
  end
  end
end
