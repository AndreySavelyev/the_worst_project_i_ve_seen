class CreateApplications < ActiveRecord::Migration
  def change
    create_table :applications do |t|
      t.string :version
      t.string :appToken
      t.datetime :validUntil

      t.timestamps
    end
  end
end
