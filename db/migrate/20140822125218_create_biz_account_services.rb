class CreateBizAccountServices < ActiveRecord::Migration
  def change
    create_table :biz_account_services do |t|
      t.string :pic, :null => false
      t.string :api_data
      t.belongs_to :profile, index: true

      t.timestamps
    end
  end
end
