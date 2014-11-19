module ChatHelper

  def self.format_tissue(tissue)
    {
        :id => tissue.id,
        :message => tissue.text,
        :from => "#{tissue.from_profile.name} #{tissue.from_profile.surname}",
        :from_id => tissue.from_profile.user_token,
        :from_email => tissue.from_profile.email,
        :to => "#{tissue.to_profile.name} #{tissue.to_profile.surname}",
        :to_id => tissue.to_profile.user_token,
        :to_email => tissue.to_profile.email,
        :date => tissue.created_at.to_s(:session_date_time),
        :pic => tissue.from_profile.avatar_url
    }
  end

  def self.get_tissue_message_format (tissue_list)
    tissues = Array.new
    if tissue_list
      tissue_list.each { |tissue|
        tissues << format_tissue(tissue)
      }
    end
    return tissues
  end
end
