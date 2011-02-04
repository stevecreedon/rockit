require 'spec_helper'

describe Core::Command do
  
  before(:each) do
    Sockit.stubs(:name).returns('Test Command')
  end
  
  it 'should return the name of the running environment' do
    Core::Command.new.environment.should == 'test'
  end
  
  it 'should return the name of the running environment' do
    Core::Command.new.environment.should == 'test'
  end
  
  it 'should call set_up, run and tear_down on start' do
    command = Core::Command.new
    command.expects(:set_up)
    command.expects(:run)
    command.expects(:tear_down)
    command.start
  end
  
  module MyTester
    class Main < Core::Command
    
    end
  end
  
  it 'should log the correct message to the current environment' do
    Time.stubs(:now).returns(Time.parse('Mon Jan 10 16:40:00 +0000 2011'))
    Log4r::Logger['test'].expects(:info).with("Application:my_tester, Mon Jan 10 16:40:00 +0000 2011, warning!!!")
    command = MyTester::Main.new
    command.info("warning!!!")
  end
  
  describe 'dynamic attributes' do
    
    it 'should return the existing attribute value where the method name matches the value key' do
      command = Core::Command.new(:name => 'steve', :email => 'steve@steve.com')
      command.name.should == 'steve'
      command.email.should == 'steve@steve.com'
    end
    
    it 'should assign a new atribute' do
      command = Core::Command.new(:name => 'florin')
      command.name='steve'
      command.name.should == 'steve'
    end
    
    it 'should raise an error if the assigned value doesn\'t match any predefined keys' do
      command = Core::Command.new(:name => 'non-existing-key')
      lambda do
        command.non_existing_method = 123
      end.should raise_error(NoMethodError)
    end
    
    it 'should raise an error if the reuested value doesn\'t match any predefined keys' do
      command = Core::Command.new(:name => 'non-existing-key')
      lambda do
        command.non_existing_method
      end.should raise_error(NoMethodError)
    end
    
  end
  
  describe 'helpers' do
      
    class ConfigTester < Core::Command
      
    end
      
    it 'should return the path of the folder the application runs in' do
      command = ConfigTester.new
      command.root.should == 'apps/config_tester'
    end
    
    it 'should load the config file in the same folder as the application' do
      Sockit.stubs(:app_root).returns('spec/apps')
      command = ConfigTester.new
      command.local_config["test"].should == {"xyz" => 123}
    end
    
    it 'should load the config file in the same folder as the application' do
      Sockit.stubs(:service_root).returns('spec/services/service_classes')
      command = ConfigTester.new
      command.service_config(:dummy)["test"]["name"].should == "yipee"
    end
    
  end
  
  describe 'services' do
    
clazz = <<CLASS
    class Dummy < Core::Command
      services :dummy
    end
CLASS

    it 'should respond to the test method in the included service module' do
      Sockit.stubs(:service_root).returns("spec/services/service_classes")
      eval clazz
      Dummy.new.respond_to?(:dummy_method).should be_true
    end
      
  end
  
  
  
  
end