class CreateShops < ActiveRecord::Migration
  def change
    create_table :shops do |t|
      t.string :name
      t.integer :profile_id
      t.string :text
      t.timestamps
    end
  end
end
