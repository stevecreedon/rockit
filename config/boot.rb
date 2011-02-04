require 'config/preinitializer'
require 'config/sockit'
require 'active_support/inflector'
require 'log4r'
require 'yaml'
require 'active_record'
 
module Boot
  
  LOADED = []

  class << self
    
    def load(arg=:application)
        self.send("load_#{arg}".to_sym)
    end

    def arg(key, args={})
      index = Sockit.args.index(key)
      raise ArgumentError, "The switch #{key} does not exist" if index.nil? and args[:required]
      return nil if index.nil? 
      return Sockit.args[index + 1]
    end

    def params
      params = {}
      Sockit.args.each_with_index do |arg, i|
        params[arg.gsub("--","")] = Sockit.args[i + 1] if arg.start_with?("--")
      end
      params.each{|key, value| params[key] = nil if (value && value.start_with?("-"))}
      params
    end

    def depends(*dependencies)
      dependencies.each do |dependency|
        self.send("load_#{dependency}".to_sym) unless LOADED.include?(dependency)
        Boot::LOADED << dependency 
      end
    end
    
    def load_logging
      depends(:environment)
      environment = Sockit.environment
      log = Log4r::Logger.new(environment)
      log.outputters = Log4r::FileOutputter.new(environment.to_s, :filename => "log/#{environment}")
      Log4r::Logger[environment].info("starting #{environment}")
    end

    def load_core
      depends(:environment, :logging)
      Dir.glob("lib/**/*.rb").each do |f|
        require f
      end

      Dir.glob("core/**/*.rb").each do |f|
        require f
      end
    end

    def load_environment
      depends #on nothing
      Sockit.environment ||= arg("-e") || "development"
      require 'config/environment'
    end
    
    def load_active_record_connection
      depends(:environment)
      connection_hash = YAML.load_file("config/database.yml")[Sockit::APP[:environment].to_s]
      raise "unable to find database details for environment '#{Sockit::APP[:environment]}'" if connection_hash.nil?
      ActiveRecord::Base.establish_connection(connection_hash)
    end

    def load_application
      depends(:environment, :logging, :core)
      application = arg("-a")
      raise "no application specified" if application.nil?
      raise "the application #{application} does not exist" unless File.directory?(File.join(File.dirname(__FILE__),'..','apps', application))
  
      Dir.glob("#{Sockit.app_root}/#{application}/*.rb").each do |f|
        require f
      end

      clazz = "#{application.camelize}::#{(arg("-c") || "Main")}".constantize
      raise "the entry class #{clazz} is not an instance of Core::Command" unless clazz.superclass == Core::Command

      Sockit.command = clazz.new(params)
      Sockit.name = application
    end
    
    def load_service(name)
      depends(:environment)
      Dir.glob("#{Sockit.service_root}/#{name}/*.rb").each do |f|
        require f
      end
    end

    def load_tasks
      depends(:environment, :active_record_connection)
      Dir.glob("lib/**/*.rake").each do |f|
        Kernel.load f
      end
    end
   
  
  end

end





