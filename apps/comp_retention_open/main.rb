module CompRetentionOpen
  class Main < Core::Command
      
      def set_up
        Boot.load(:active_record_connection)
      end
     
      def run
        members = Member.where(:email_sent => nil).order(:email_address)      
        members.each do |member|
         send_to_360(member.email_address,local_config["template"]["name"], custom_data(member))
         member.email_sent = Time.now
         member.email_success = true
         member.save!
       end
      end
      
      def tear_down
        #main code goes here
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
