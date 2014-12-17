class ChangeLimitCurrencyType < ActiveRecord::Migration
  def change
    change_column :limits, :currency, :string
  end
end
