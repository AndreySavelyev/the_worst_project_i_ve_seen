class CreateHotOffers < ActiveRecord::Migration
  def change
    create_table :hot_offers do |t|
      t.string :title
      t.string :currency
      t.string :pic_url
      t.integer :price
      t.belongs_to :profile, index: true

      t.timestamps
    end
  end
end
