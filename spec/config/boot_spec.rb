require 'spec_helper'

describe Boot do
  
  describe 'parsing args' do
      
     it 'should return the argument after the specified switch' do
       Sockit.stubs(:args).returns(["-a","test","-s", "another switch"])
       Boot.arg("-a").should == "test"
     end
   
     it 'should return nil when there is no argument after the specified switch' do
        Sockit.stubs(:args).returns(["-a","test","-s"])
        Boot.arg("-s").should be_nil
     end
   
     it 'should raise an error when the argument does not exist but is required' do
         Sockit.stubs(:args).returns(["-a","test","-s", "another switch"])
         lambda do
           Boot.arg("-x", :required => true)
         end.should raise_error(ArgumentError, "The switch -x does not exist")
     end
     
     it 'should return nil when the argument does not exist and is not required' do
          Sockit.stubs(:args).returns(["-a","test","-s", "another switch"])
          Boot.arg("-x").should be_nil
     end
   
  end
  
  describe 'extracting params from the args' do
    
    it 'should return the values after switches staring -- as key value pairs in a hash' do
       Sockit.stubs(:args).returns(["-a","test","-s","--name" ,"steve", "another switch", "--email", "steve@steve.steve"])
       Boot.params.should == {"name" => "steve", "email" => "steve@steve.steve"}
    end
    
    it 'should set the param value to nil if the value after the switch is nil or is another switch (starts with - or --)' do
       Sockit.stubs(:args).returns(["-a","test","-s","--name" ,"steve", "another switch", "--email", "-v","--address","--something"])
       Boot.params.should == {"address"=>nil, "name"=>"steve", "something"=>nil, "email"=>nil}
    end
    
  end
  
  describe 'load_environment' do
    
    it 'should set the environemnt to that in the -e switch' do
      Sockit::APP.delete(:environment)
      Sockit.stubs(:args).returns(["-e","desert"])
      Boot.load_environment
      Sockit::APP[:environment].should == "desert"
    end
    
    it 'should not set the environment if one already has been set explicitly' do
      Sockit::APP[:environment] = "xyz"
      Sockit.stubs(:args).returns(["-e","desert"])
      Boot.load_environment
      Sockit::APP[:environment].should == "xyz"
    end
    
    it 'should not set the environment to development if one is not supplied as an argument' do
      Sockit::APP.delete(:environment)
      Sockit.stubs(:args).returns(["-x","desert"])
      Boot.load_environment
      Sockit::APP[:environment].should == "development"
    end
    
  end
  
  describe 'load_active_record_connection' do
    
    it 'should set the ActiveRecord connection to that in the environment' do
      Sockit.environment = "blah"
      YAML.stubs(:load_file).with("config/database.yml").returns({"blah" => {"blah_user" => "abc", "blah_pwd" => "xyz"}})
      ActiveRecord::Base.expects(:establish_connection).with({"blah_user" => "abc", "blah_pwd" => "xyz"})
      Boot.load_active_record_connection
      Sockit.environment = "test"
    end
    
  end
  
end
