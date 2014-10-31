class Mood < ActiveRecord::Base

  belongs_to :Profile

  def self.mood(profile_id, mood_type)
    mood = Mood.new
    mood.index = mood_type
    mood.profile_id = profile_id
    mood.save!
  end

end
