Factory.define "CompRetentionOpen::Member" do |member|
      member.email_address 'test@test.gamesys.co.uk'
      member.subject_line 'member-subject-line'
      member.partner_name 'partner-name'
      member.partner_asset_folder 'partner-asset-folder'
      member.partner_site 'partner-site'
      member.member_name 'member-user-name'
      member.first_name 'first_name'
      member.footer 'footer'
      member.template 'content'
      member.comp_expiry_date 'comp-expiry-date'
end