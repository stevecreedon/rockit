clazz = <<clazz
module sockit_clazz
  class Main < Core::Command
      
      def set_up
        #main code goes here
      end
     
      def run
        #main code goes here
      end
      
      def tear_down
        #main code goes here
      end
      
  end
end
clazz

spec =<<spec
require 'spec_helper'

describe sockit_clazz::Main do
  it 'should do something pretty spectacular' do
    
  end
end
spec

namespace :sockit do
  task :app, [:name] do |t, args| 
     FileUtils.mkdir(File.join("apps", args[:name]))
     FileUtils.mkdir(File.join("spec", "apps", args[:name]))
     File.open("apps/#{args[:name]}/main.rb", 'w') {|f| f.write(clazz.gsub("sockit_clazz",args[:name].camelize)) }
     File.open("spec/apps/#{args[:name]}/main.rb", 'w') {|f| f.write(spec.gsub("sockit_clazz",args[:name].camelize)) }
  end
end

