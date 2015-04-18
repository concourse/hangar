require "yaml"

require "archive/tar/minitar"

module Hangar
  class Release
    def initialize(path)
      @path = path
    end

    def name
      manifest.fetch("name")
    end

    def version
      manifest.fetch("version")
    end

    def file
      File.basename(path)
    end

    private

    def manifest
      @manifest ||= YAML.load(manifest_file_contents)
    end

    def manifest_file_contents
      tgz = Zlib::GzipReader.new(File.open(path, 'rb'))

      Archive::Tar::Minitar::Reader.open(tgz) do |reader|
        reader.each_entry do |entry|
          next unless File.basename(entry.full_name) == "release.MF"

          return entry.read
        end
      end

      raise "could not find release.MF"
    ensure
      tgz.close if tgz
    end

    attr_reader :path
  end
end
