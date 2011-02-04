module Services
  module ThreeSixtyApi
    class Session
      
      attr_accessor :config, :wsdl, :session_id
      
      def initialize(config, wsdl)
        self.config = config
        self.wsdl = wsdl
      end
      
      def client
        @client ||= Savon::Client.new do |wsdl, http, wsse|
          wsdl.document = self.wsdl
          wsdl.endpoint = config["url"]
        end
      end
      
      def send_to_360(template, *data)
        data.flatten!
        self.session_id = login
        data.each do |d|
          creation_id = create(d[:email], template, d[:custom_data])
          store(creation_id)
        end
        
        logout
      end
      
      def login
         response = self.client.request :n1, :handleRequest, "xmlns:n1" => "urn:localhost-paint" do
            soap.body = {
              :context_id => nil,
              :class_name => 'bus_facade_context',
              :process_name => 'login',
              :entity_data => {"n2:pairs" => [pair('userName', config["user_name"]), pair('password', config["password"])]},
              :process_data => nil,
              :attributes! => {:entity_data => {"xmlns:n2" => "http://www.pure360.com/paint"}},
              :order! => [:context_id, :class_name, :process_name, :entity_data, :process_data]
            }
          end
          Session.extract_id('bus_entity_context', response.to_xml)
      end
      
      def create(email, template, custom_data)
          response = self.client.request :n1, :handleRequest, "xmlns:n1" => "urn:localhost-paint" do
               soap.body = {
                 :context_id => self.session_id,
                 :class_name => 'bus_facade_campaign_one2one',
                 :process_name => 'create',
                 :entity_data => {"n2:pairs" => [pair('toAddress', email), 
                                                 pair('deliveryDtTm', (Time.now + 70).strftime('%d/%m/%Y %H:%M')),
                                                 pair('customData', custom_data)]},
                 :process_data => {"n2:pairs" => [pair('message_messageName', template)]},
                 :attributes! => {:entity_data => {"xmlns:n2" => "http://www.pure360.com/paint"}}
               }
           end
           Session.extract_id('bus_entity_campaign_one2one', response.to_xml)
      end
      
      def store(creation_id)
         response = self.client.request :n1, :handleRequest, "xmlns:n1" => "urn:localhost-paint" do
              soap.body = {
                :context_id => self.session_id,
                :class_name => 'bus_facade_campaign_one2one',
                :process_name => 'store',
                :entity_data => {"n2:pairs" => pair('beanId', creation_id)},
                :process_data => nil,
                :attributes! => {:entity_data => {"xmlns:n2" => "http://www.pure360.com/paint"}}
              }
          end
      end
      
      def logout
         response = client.request :n1, :handleRequest, "xmlns:n1" => "urn:localhost-paint" do
               soap.body = {
                 :context_id => self.session_id,
                 :class_name => 'bus_facade_context',
                 :process_name => 'logout',
                 :entity_data => {"n2:pairs" => {}},
                 :process_data => nil,
                 :attributes! => {:entity_data => {"xmlns:n2" => "http://www.pure360.com/paint"}}
               }
        end
      end
      
      def pair(key, value)
        Session.pair(key, value)
      end
      
      
      def self.pair(key, value)
          return {"n2:key" => key, "n2:value" => {"n2:str" => value}} if value.is_a?(String)
          return {"n2:key" => key, "n2:value" => {"n2:arr" => {"n2:pairs" => value.collect{|k, v| pair(k,v)}}}} if value.is_a?(Hash)
      end
      
      ID_PATTERN = /<ns2:key>beanId<\/ns2:key><ns2:value><ns2:str>([A-Z,a-z,0-9]*)/
      
      def self.extract_id(bus_entity, xml)
        pos = (xml =~ Regexp.new(bus_entity))
        raise "unable to find a bus entity #{bus_entity}" unless pos
        id = ID_PATTERN.match(xml[pos..-1])
        raise "unable to find a guid for #{bus_entity}" unless $1
        $1
      end
      
      
      
      
    end
  end
end