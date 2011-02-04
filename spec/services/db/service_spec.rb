require 'spec_helper'
require 'services/db/db_service'

clazz = <<def
   class FauxCommand
     include Services::Db::DbService
   end
def

describe 'Services::Db::DbService' do
   it 'should connect to the database using the test details in the test config/database.yml' do
     Boot.expects(:load_active_record_connection)     
     eval clazz
   end
end

