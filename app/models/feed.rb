class Feed < ActiveRecord::Base
  belongs_to  :from_profile, :class_name => 'Profile'#, :foreign_key => :from_profile_id
  belongs_to :to_profile , :class_name => 'Profile'#, :foreign_key => :to_profile_id
end
