require 'fileutils'
require 'optparse'
require 'zip'

module Hangar
  class Cli
    def initialize(argv)
      @argv = argv
    end
    
    def run!
      stemcell = Dir[File.join(stemcell_dir, '*')].first
      release = Dir[File.join(release_dir, '*')].first

      raise "Could not find a stemcell in directory: #{stemcell_dir}" if stemcell.nil?
      raise "Could not find a release in directory: #{release_dir}" if release.nil?

      filename = "#{product_name}.pivotal"
      Zip::File.open(filename, Zip::File::CREATE) do |zip|
        zip.add(File.join('stemcells', File.basename(stemcell)), stemcell)
        zip.add(File.join('releases', File.basename(release)), release)
      end
    end

    private

    attr_reader :argv

    def product_name
      parsed_options.fetch(:product_name) {
        raise OptionParser::MissingArgument, 'Please specify a product name (--product-name)'
      }
    end

    def stemcell_dir
      parsed_options.fetch(:stemcell_dir) {
        raise OptionParser::MissingArgument, 'Please specify a stemcell directory (--stemcell-dir)'
      }
    end

    def release_dir
      parsed_options.fetch(:release_dir) {
        raise OptionParser::MissingArgument, 'Please specify a release directory (--release-dir)'
      }
    end

    def parsed_options
      return @parsed_options if @parsed_options

      options = {}
      OptionParser.new do |opts|
        opts.on('-n', '--product-name NAME', 'name of product to create') do |r|
          options[:product_name] = r
        end

        opts.on('-s', '--stemcell-dir DIR', 'directory containing stemcell') do |s|
          options[:stemcell_dir] = s
        end

        opts.on('-r', '--release-dir DIR', 'directory containing release') do |r|
          options[:release_dir] = r
        end
      end.parse!(argv)

      @parsed_options = options
    end
  end
end
