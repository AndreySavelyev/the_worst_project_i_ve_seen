class CreateProfiles < ActiveRecord::Migration
  def change
    create_table :profiles do |t|
      t.string :user_token
      t.string :fb_token
      t.string :pic_url
      t.string :name
      t.string :surname
      t.string :phone
      t.string :iban
      t.string :reg_num
      t.datetime :birthday
      t.string :company_name
      t.string :email
      t.string :password
      t.string :salt
      t.datetime :created_at
      t.datetime :updated_at
      t.integer :result
      t.string :message

          t.timestamps
    end
  end
end
