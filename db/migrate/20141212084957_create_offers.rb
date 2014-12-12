class CreateOffers < ActiveRecord::Migration
  def change
    create_table :offers do |t|
      t.string :text
      t.decimal :price
      t.decimal :old_price
      t.integer :currency
      t.integer :shop_id
      t.timestamps
    end
  end
end
