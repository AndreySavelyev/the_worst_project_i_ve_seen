class AddCurrencyToEntries < ActiveRecord::Migration

  def up
    add_column :entries, :currency, :string

    execute <<-SQL
        UPDATE entries SET currency = iso_currencies."Alpha3Code" FROM iso_currencies WHERE CAST (entries."currency_id" AS integer) = iso_currencies.id
    SQL
  end

  def down
    remove_column :entries, :currency
  end

end
