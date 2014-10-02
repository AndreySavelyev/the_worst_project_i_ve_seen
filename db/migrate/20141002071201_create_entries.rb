class CreateEntries < ActiveRecord::Migration
  def change
    create_table :entries do |t|
      t.integer :payment_request_id, :null => false
      t.integer :credit_profile_id, :null => false
      t.integer :debt_profile_id, :null => false
      t.float :amount, :null => false
      t.string :currency_id, :limit => 3, :null => false
      t.integer :operation_code, :null => false

      t.timestamps
    end
  end
end
