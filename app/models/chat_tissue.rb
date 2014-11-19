class ChatTissue < ActiveRecord::Base

  belongs_to  :from_profile, :class_name => 'Profile'
  belongs_to :to_profile , :class_name => 'Profile'

  def self.send_tissue(from_profile_id, to_profile_id, text)
    tissue = ChatTissue.create
    tissue.text = text
    tissue.from_profile_id = from_profile_id
    tissue.to_profile_id = to_profile_id
    tissue.save!
    ChatHelper::format_tissue(tissue)
  end

  def self.get_tissues(from_profile_id, to_profile_id)
    ChatTissue.where('(from_profile_id = :from_profile_id AND to_profile_id = :to_profile_id) OR (from_profile_id = :to_profile_id AND to_profile_id = :from_profile_id)',
                     from_profile_id: from_profile_id,
                     to_profile_id: to_profile_id).includes(:from_profile, :to_profile).order(id: :desc).first(100)
  end

end
