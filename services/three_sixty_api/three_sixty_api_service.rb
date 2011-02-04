require 'savon'

module Services
  module ThreeSixtyApi
    module ThreeSixtyApiService
      def send_to_360(template, *data)
          data.flatten!
          config = service_config(:three_sixty_api)[Sockit.environment]
          wsdl = File.join(service_dir(:three_sixty_api),"ctrlPaintLiteral.wsdl")
          session = Services::ThreeSixtyApi::Session.new(config, wsdl)
          session.send_to_360(template, data)
      end
    end
  end
end