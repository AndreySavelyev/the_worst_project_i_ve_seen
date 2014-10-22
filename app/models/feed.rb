class Feed < ActiveRecord::Base
  belongs_to  :from_profile, :class_name => 'Profile'
  belongs_to :to_profile , :class_name => 'Profile'
  
  has_one :wallet_request, :class_name => 'WalletRequest', dependent: :nullify
  
  def self.get_new(user)
    Feed.where("to_profile_id = :id AND status = 0", id: user.id).count
  end
  
end
