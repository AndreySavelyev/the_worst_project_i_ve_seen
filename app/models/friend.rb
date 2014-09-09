class Friend < ActiveRecord::Base
  belongs_to :patient, :class_name => 'Profile', :foreign_key => 'profile_id'
  belongs_to :lover, :class_name => 'Profile', :foreign_key => 'friend_id'
end
