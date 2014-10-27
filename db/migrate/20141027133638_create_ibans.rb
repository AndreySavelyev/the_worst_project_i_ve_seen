class CreateIbans < ActiveRecord::Migration
  def change
    create_table :ibans do |t|
      t.integer :profile_id
      t.string :iban_num
      t.boolean :verified
      t.integer :code
      t.string :wr_token

      t.timestamps
    end
  end
end
