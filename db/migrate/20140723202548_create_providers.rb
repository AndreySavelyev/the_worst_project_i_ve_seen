class CreateProviders < ActiveRecord::Migration
  def change
    create_table :providers do |t|
      t.string :pic
      t.string :apiData
      t.belongs_to :application, index: true

      t.timestamps
    end
  end
end
