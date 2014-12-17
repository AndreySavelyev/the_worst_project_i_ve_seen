class CreateLimits < ActiveRecord::Migration
  def change
    create_table :limits do |t|
      t.string :value
      t.integer :currency
      t.integer :wallet_type
      t.timestamps
    end
  end
end
