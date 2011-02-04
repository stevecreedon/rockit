module Services
  module Db
    module DbService
      def self.included(base)
        Boot.load_active_record_connection
      end
    end
  end
end