class CreateChangeRates < ActiveRecord::Migration
  def change
    create_table :change_rates do |t|
      t.integer :CurrencyTo
      t.integer :CurrencyFrom
      t.integer :Rate
      t.datetime :SetUpDate

      t.timestamps
    end
  end
end
