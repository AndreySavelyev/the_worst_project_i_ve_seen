class CreateMoods < ActiveRecord::Migration
  def change
    create_table :moods do |t|
      t.integer :index
      t.integer :profile_id
      t.timestamps
    end
  end
end
