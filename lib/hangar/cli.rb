require 'fileutils'
require 'optparse'
require 'zip'

module Hangar
  class Cli
    def initialize(argv)
      @argv = argv
    end
    
    def run!
      raise OptionParser::MissingArgument, 'Please specify a product name (--product-name)' unless parsed_options.has_key?(:product_name)

      stemcell = Dir[File.join(stemcell_dir, '*')].first
      release = Dir[File.join(release_dir, '*')].first

      raise "Could not find a stemcell in directory: #{stemcell_dir}" if stemcell.nil?
      raise "Could not find a release in directory: #{release_dir}" if release.nil?

      filename = "#{parsed_options.fetch(:product_name)}.pivotal"
      Zip::File.open(filename, Zip::File::CREATE) do |zip|
        zip.add(File.join('stemcells', File.basename(stemcell)), stemcell)
        zip.add(File.join('releases', File.basename(release)), release)
      end
    end

    private

    attr_reader :argv

    def stemcell_dir
      parsed_options.fetch(:stemcell_dir)
    end

    def release_dir
      parsed_options.fetch(:release_dir)
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
