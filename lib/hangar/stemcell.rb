module Hangar
  class Stemcell
    def initialize(path)
      @path = path
    end

    def name
      parts = file.split("-")
      name = [parts[0], parts[3], parts[4], parts[5], parts[6], parts[7]].join("-")
      File.basename(name, File.extname(name))
    end

    def file
      File.basename(@path)
    end

    def version
      @path.match(/[\d\.]+/)[0]
    end
  end
end
