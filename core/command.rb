module Core
  class Command
    
    class << self
      def services(*args)
        load_services(args)
      end
      
      def load_services(args)
        args.each do |service|
          Boot.load_service(service)
          include "Services::#{service.to_s.classify}::#{service.to_s.classify}Service".constantize
        end
      end
    end
    
    def initialize(args={})
      @attributes = args
    end
    
    def method_missing(sym, *args)
      return @attributes[sym] if @attributes.has_key?(sym)
      attribute = sym.to_s.chomp("=").to_sym
      if sym.to_s.end_with?("=") and @attributes.has_key?(attribute)
        @attributes[attribute] = args.first
        return
      end 
      super
    end
    
    def start
      set_up
      run
      tear_down
    end
    
    def set_up
      info("set up")
    end
  
    def run
      raise "run has not been overriden for this app"
    end
    
    def tear_down
      info("tear down")
    end
    
    def environment
      Sockit.environment
    end
    
    def application_name
      self.class.name.split("::").first.underscore
    end
    
    def root
      File.join("#{Sockit.app_root}", self.application_name) 
    end
        
    def local_config
      YAML.load_file(File.join(root,'config.yml'))
    end
    
    def service_config(name)
      YAML.load_file(File.join(service_dir(name), 'config.yml'))
    end
    
    def service_dir(name)
      File.join(Sockit.service_root, name.to_s)
    end
    
    def info(message)
      Log4r::Logger[environment].info("Application:#{self.application_name}, #{Time.now}, #{message}")
    end
        
  end
end