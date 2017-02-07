require 'fileutils'
require 'optparse'
require 'zip'

require 'hangar/content_migrations'
require 'hangar/metadata_template'
require 'hangar/release'

module Hangar
  class Cli
    def initialize(argv)
      @argv = argv
    end

    def run!
      release_paths = release_dirs.map do |dir|
        release_paths = Dir[File.join(dir, '*.tgz')]
        raise "Could not find a release in directory: #{dir}" if release_paths.empty?
        release_paths
      end.flatten!

      raise "Could not find a metadata template: #{metadata_template}" unless File.exist?(metadata_template)
      raise "Could not find a content migrations template: #{content_migrations}" unless File.exist?(content_migrations)

      migrations_path = migrations_dir.map do |dir|
        migrations_path = Dir[File.join(dir)]
        raise "Could not find migrations directory: #{dir}" if migrations_path.empty?
        migrations_path
      end.flatten!

      filename = "#{product_name}-#{product_version}.pivotal"
      Zip::File.open(filename, Zip::File::CREATE) do |zip|
        release_paths.each do |path|
          zip.add(File.join('releases', File.basename(path)), path)
        end

        zip.get_output_stream('metadata/metadata.yml') do |os|
          os.write template_result(release_paths, product_version)
        end

        zip.get_output_stream('content_migrations/migrations.yml') do |os|
          os.write content_migration_result(product_version)
        end

        migrations_path.each do |path|
          zip.add(File.join('migrations', File.basename(path)), path)
        end
      end
    end

    private

    attr_reader :argv

    def content_migration_result(product_version)
      ContentMigrations.from_file(content_migrations).result(product_name, product_version)
    end

    def template_result(release_paths, product_version)
      releases = release_paths.map { |path| Release.new(path) }

      MetadataTemplate.from_file(metadata_template).result(product_name, product_version, stemcell_version, releases)
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

    def stemcell_version
      options.fetch(:stemcell_version) {
        raise OptionParser::MissingArgument, 'Please specify a stemcell version (--stemcell-version)'
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

    def content_migrations
      options.fetch(:content_migrations) {
        raise OptionParser::MissingArgument, 'Please specify a content migrations template (--content-migrations)'
      }
    end

    def migrations_dir
      dir = options.fetch(:migrations_dir)

      if dir.empty?
        raise OptionParser::MissingArgument, 'Please specify a migrations directory (--migrations)'
      end

      dir
    end

    def options
      return @parsed_options if @parsed_options

      options = {
        release_dirs: [],
        migrations_dir: []
      }

      OptionParser.new do |opts|
        opts.on('-n', '--product-name NAME', 'name of product to create') do |p|
          options[:product_name] = p
        end

        opts.on('-v', '--product-version VERSION', 'version of product to create') do |v|
          options[:product_version] = v
        end

        opts.on('-s', '--stemcell-version VERSION', 'version of stemcell to require in product') do |v|
          options[:stemcell_version] = v
        end

        opts.on('-r', '--release-dir DIR', 'directory containing release') do |r|
          options[:release_dirs] << r
        end

        opts.on('-m', '--metadata-template FILE', 'metadata template file') do |m|
          options[:metadata_template] = m
        end

        opts.on('-c', '--content-migrations FILE', 'content migrations file') do |c|
          options[:content_migrations] = c
        end

        opts.on('-g', '--migrations DIR', 'directory containing javascript migrations') do |g|
          options[:migrations_dir] << g
        end
      end.parse!(argv)

      @parsed_options = options
    end
  end
end
