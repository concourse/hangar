module Hangar
  class Release
    def initialize(path)
      @path = path
    end
    
    def name
      file.split("-")[0..-2].join("-")
    end
    
    def file
      File.basename(@path)
    end
    
    def version
      @path.match(/[\d\.]*\d/)[0]
    end
  end
end