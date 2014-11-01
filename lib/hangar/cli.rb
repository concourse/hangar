require 'fileutils'
require 'optparse'
require 'zip'

require 'hangar/metadata_template'
require 'hangar/release'
require 'hangar/stemcell'

module Hangar
  class Cli
    def initialize(argv)
      @argv = argv
    end

    def run!
      stemcell_path = Dir[File.join(stemcell_dir, '*.tgz')].first
      raise "Could not find a stemcell in directory: #{stemcell_dir}" if stemcell_path.nil?
      
      release_paths = release_dirs.map do |dir|
        release_path = Dir[File.join(dir, '*.tgz')].first
        raise "Could not find a release in directory: #{dir}" if release_path.nil?
        release_path
      end

      raise "Could not find a metadata template: #{metadata_template}" unless File.exist?(metadata_template)

      filename = "#{product_name}-#{product_version}.pivotal"
      Zip::File.open(filename, Zip::File::CREATE) do |zip|
        zip.add(File.join('stemcells', File.basename(stemcell_path)), stemcell_path)
        
        release_paths.each do |path|
          zip.add(File.join('releases', File.basename(path)), path)
        end

        zip.get_output_stream('metadata/metadata.yml') do |os|
          os.write template_result(stemcell_path, release_paths, product_version)
        end
      end
    end

    private

    attr_reader :argv

    def stemcell(path)
      Stemcell.new(path)
    end

    def template_result(stemcell_path, release_paths, product_version)
      stemcell = stemcell(stemcell_path)
      releases = release_paths.map { |path| Release.new(path) }

      MetadataTemplate.from_file(metadata_template).result(product_name, product_version, stemcell, releases)
    end

    def product_name
      options.fetch(:product_name) {
        raise OptionParser::MissingArgument, 'Please specify a product name (--product-name)'
      }
    end

    def product_version
      options.fetch(:product_version) {
        raise OptionParser::MissingArgument, 'Please specify a product version (--product-version)'
      }
    end

    def stemcell_dir
      options.fetch(:stemcell_dir) {
        raise OptionParser::MissingArgument, 'Please specify a stemcell directory (--stemcell-dir)'
      }
    end

    def release_dirs
      dirs = options.fetch(:release_dirs)

      if dirs.empty?
        raise OptionParser::MissingArgument,
          'Please specify a release directory (--release-dir)'
      end
      
      dirs
    end

    def metadata_template
      options.fetch(:metadata_template) {
        raise OptionParser::MissingArgument, 'Please specify a metadata template (--metadata-template)'
      }
    end

    def options
      return @parsed_options if @parsed_options

      options = {
        release_dirs: []
      }

      OptionParser.new do |opts|
        opts.on('-n', '--product-name NAME', 'name of product to create') do |p|
          options[:product_name] = p
        end

        opts.on('-v', '--product-version VERSION', 'version of product to create') do |v|
          options[:product_version] = v
        end

        opts.on('-s', '--stemcell-dir DIR', 'directory containing stemcell') do |s|
          options[:stemcell_dir] = s
        end

        opts.on('-r', '--release-dir DIR', 'directory containing release') do |r|
          options[:release_dirs] << r
        end

        opts.on('-m', '--metadata-template FILE', 'metadata template file') do |m|
          options[:metadata_template] = m
        end
      end.parse!(argv)

      @parsed_options = options
    end
  end
end
