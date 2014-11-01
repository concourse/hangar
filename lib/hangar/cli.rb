require 'fileutils'
require 'optparse'
require 'zip'

require 'hangar/release'
require 'hangar/stemcell'

module Hangar
  class Cli
    def initialize(argv)
      @argv = argv
    end
    
    def run!
      stemcell_path = Dir[File.join(stemcell_dir, '*')].first
      release_path = Dir[File.join(release_dir, '*')].first

      raise "Could not find a metadata template: #{metadata_template}" unless File.exist?(metadata_template)
      raise "Could not find a stemcell in directory: #{stemcell_dir}" if stemcell_path.nil?
      raise "Could not find a release in directory: #{release_dir}" if release_path.nil?

      filename = "#{product_name}.pivotal"
      Zip::File.open(filename, Zip::File::CREATE) do |zip|
        zip.add(File.join('stemcells', File.basename(stemcell_path)), stemcell_path)
        zip.add(File.join('releases', File.basename(release_path)), release_path)
        zip.get_output_stream('metadata/metadata.yml') do |os|
          os.write template_result(stemcell_path, release_path)
        end
      end
    end

    private

    attr_reader :argv
    
    def stemcell(path)
      Stemcell.new(path)
    end
    
    def template_result(stemcell_path, releases_path)
      stemcell = stemcell(stemcell_path)
      releases = [
        Release.new(releases_path)
      ]
      MetadataTemplate.from_file(metadata_template).result(product_name, "0.1", stemcell, releases)
    end

    def product_name
      options.fetch(:product_name) {
        raise OptionParser::MissingArgument, 'Please specify a product name (--product-name)'
      }
    end

    def stemcell_dir
      options.fetch(:stemcell_dir) {
        raise OptionParser::MissingArgument, 'Please specify a stemcell directory (--stemcell-dir)'
      }
    end

    def release_dir
      options.fetch(:release_dir) {
        raise OptionParser::MissingArgument, 'Please specify a release directory (--release-dir)'
      }
    end
    
    def metadata_template
      options.fetch(:metadata_template) {
        raise OptionParser::MissingArgument, 'Please specify a metadata template (--metadata-template)'
      }
    end

    def options
      return @parsed_options if @parsed_options

      options = {}
      OptionParser.new do |opts|
        opts.on('-n', '--product-name NAME', 'name of product to create') do |p|
          options[:product_name] = p
        end

        opts.on('-s', '--stemcell-dir DIR', 'directory containing stemcell') do |s|
          options[:stemcell_dir] = s
        end

        opts.on('-r', '--release-dir DIR', 'directory containing release') do |r|
          options[:release_dir] = r
        end
        
        opts.on('-m', '--metadata-template FILE', 'metadata template file') do |m|
          options[:metadata_template] = m
        end
      end.parse!(argv)

      @parsed_options = options
    end
  end
end
