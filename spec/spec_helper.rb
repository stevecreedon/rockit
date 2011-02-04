require 'config/sockit'
require 'config/boot'
require 'active_record'
require 'factory_girl'
require 'spec/factories'
require 'xmlsimple'

Sockit.environment = 'test'
Boot.load(:core)
Boot.load(:active_record_connection)

require 'rspec'
require 'mocha'

Dir.glob("apps/*/*.rb").each do |f|
   load f
end

RSpec.configure do |config|
   config.mock_with :mocha
end

def compare_xml(xmla, xmlb)
  XmlSimple.xml_in(xmla) == XmlSimple.xml_in(xmlb)
end



