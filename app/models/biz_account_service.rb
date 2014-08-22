class BizAccountService < ActiveRecord::Base
  has_one :Profile, :foreign_key => 'profile_id', :class_name => "Profile"
end
