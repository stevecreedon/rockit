require 'spec_helper'

describe Sockit do
  
  it 'should return the value in the APP hash via a method call that matches the key' do
    
    Sockit::APP[:xyz] = 123 
    Sockit.xyz.should == 123
    
  end
  
  it 'should assign the non-existant value to the APP hash' do
    Sockit.abc = 123
    Sockit::APP[:abc].should == 123 
  end
  
  it 'should re-assign the non-existant value to the APP hash' do

     Sockit::APP[:abc] = 567
     Sockit.abc = 789
     Sockit::APP[:abc].should == 789

   end
    
end