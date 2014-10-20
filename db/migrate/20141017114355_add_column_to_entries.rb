class AddColumnToEntries < ActiveRecord::Migration
  def change    
    add_column :entries, :credit_wallet_id, :integer, :null => false
    add_column :entries, :debit_wallet_id, :integer, :null => false   
  end
end
