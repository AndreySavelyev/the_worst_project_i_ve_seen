class CreateIsoCurrencies < ActiveRecord::Migration
  def change
    create_table :iso_currencies do |t|
      t.string :Alpha3Code, limit: 3
      t.integer :Numeric3Code
      t.string :IsoName
      t.integer :Precision

      t.timestamps
    end
  end
end
