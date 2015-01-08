class CreateServices < ActiveRecord::Migration
  def change
    create_table :services do |t|
      t.string :name
      t.string :text
      t.integer :profile_id
      t.string :meta

      t.timestamps
    end
  end
end
