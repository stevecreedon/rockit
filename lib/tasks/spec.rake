task :spec do   
   require 'spec/spec_helper'
   
   Dir.glob("spec/**/*_spec.rb").each do |s|
     require s
   end 
   
end
