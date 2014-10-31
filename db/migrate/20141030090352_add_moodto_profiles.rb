class AddMoodtoProfiles < ActiveRecord::Migration
  def change
    add_column :profiles, :mood, :integer, :null => 2
  end
end
