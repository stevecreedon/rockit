class Member < ActiveRecord::Base
  set_table_name :member_lifecycle
  set_primary_key :member_id
end

module Test
  class Main < Core::Command
    services :three_sixty_api
    
    def set_up
      Boot.load(:active_record_connection)
    end
    
    def run
      member = Member.all.first
      send_to_360 'Test Welcome Process', :email => 'steve.creedon@gamesys.co.uk', :custom_data => custom_data(member)
    end
    
    def custom_data(member)
      {'subject_line' => member.subject_line,
                      'partner-name' => member.partner_name,
                      'partner-asset-folder' => member.partner_asset_folder,
                      'partner-site' => member.partner_site,
                      'member-user-name' => member.member_name,
                      'first_name' => member.first_name,
                      'footer' => member.footer,
                      'content' => member.template,
                      'comp-expiry-date' => member.comp_expiry_date}
    end
    
  end
end