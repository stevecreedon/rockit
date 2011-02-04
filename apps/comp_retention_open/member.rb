module CompRetentionOpen
  class Member < ActiveRecord::Base
    set_table_name :member_lifecycle
    set_primary_key :member_id
  end
end