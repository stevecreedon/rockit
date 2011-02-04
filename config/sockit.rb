module Sockit
  APP = {}
  
  class << self
    
    def args
      ARGV
    end
    
    def config &block
      block.call self
    end
    
    def method_missing(method, *args)
      attribute = method.to_s.chomp("=").to_sym
      if method.to_s.end_with?("=")
        APP[attribute] = args.first
      else
        return APP[method]
      end
    end
    
  end
end